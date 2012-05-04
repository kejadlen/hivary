require_relative 'tile'
require_relative 'insect/all'

module Hive
  class Board
    class << self
      NEIGHBORS = [[1,0], [-1,0], [0,1], [0,-1]]

      def load(data)
        board = self.new
        board.tiles.delete([0,0])

        data.each do |player,insects|
          insects.each do |klass,locations|
            locations.each do |location|
              board[*location] = Insect.const_get(klass).new(player, location)
              player.insects << board[*location]
            end
          end
        end

        board
      end

      def neighbors(x, y)
        offset = 1 - 2 * (y % 2) # the offset in the x-axis depends on the row
        (NEIGHBORS + [[offset,1],[offset,-1]]).map {|i,j| [x+i, y+j] }.sort
      end
      
      def one_hive?(locations)
        hive = Set.new
        queue = Set[locations.first]

        until queue.empty?
          # why isn't there a Set#shift operator?
          insect = queue.first
          queue.delete(insect)

          neighbors = self.neighbors(*insect).reject do |neighbor|
            hive.include?(neighbor) or not locations.include?(neighbor)
          end

          hive << insect
          queue.merge(neighbors)
        end

        hive.length == locations.length
      end
    end

    attr_reader :tiles

    def [](*location); self.tiles[location]; end

    def []=(*location, tile)
      self.tiles[location] = tile
      tile.location = location

      # Add empty tiles as necesssary
      Board.neighbors(*location).each do |neighbor|
        self[*neighbor] ||= EmptySpace.new(self, neighbor)
      end unless tile.empty_space?
    end

    def delete(tile); self.tiles.delete(tile.location) end

    def initialize
      @tiles = { [0,0] => EmptySpace.new(self, [0,0]) }
    end

    # def remove_empty_spaces!
      # self.tiles.select {|_,tile| tile.empty_space? }.each do |location,space|
        # self.tiles.delete(location) if space.neighbors[:insects].empty?
      # end
    # end

    def can_slide?(a, b)
      return false unless self[*b].empty_space?
      return false unless Board.neighbors(*a).include?(b)

      not (Board.neighbors(*a) & Board.neighbors(*b)).all? do |neighbor|
        not self[*neighbor].empty_space? rescue false
      end
    end

    def empty_spaces
      self.tiles.select {|_,v| v.empty_space? }.map {|_,v| v }
    end

    def insects
      self.tiles.reject {|_,v| v.empty_space? }.map {|_,v| v }
    end

    def to_s
      min_x = 0 # so each row can be offset correctly
      rows = Hash.new {|h,k| h[k] = Hash.new } # remapping the tiles to be indexed by coordinates

      # Get a row-by-row hash of the board, storing each tile as a colored letter
      self.tiles.each do |location,tile|
        min_x = [min_x, location[0]].min

        color = (tile.empty_space?) ? 37 : (tile.player.current_player?) ? 32 : 31
        rows[location[1]][location[0]] = "\e[#{color}m#{tile.class.to_s.split('::').last[0]}\e[0m"
      end

      # Transform the hash into the output string
      output = rows.sort_by {|k,_| k }.reverse.inject('') do |n,(i,row)|
        # Fill in the empty spaces
        row = Array.new(row.keys.max - min_x + 1) {|j| row[j+min_x] or ' ' }

        n << ' ' if i % 2 == 0 # offset for even rows
        n << row.join(' ') << "\n"
      end

      output.chomp
    end
  end
end
