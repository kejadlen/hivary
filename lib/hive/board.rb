require 'delegate'

require 'hive/stack'
require 'hive/insect/all'

module Hive
  class Board < Delegator
    attr_reader :source
    def __getobj__; @source; end

    class << self
      NEIGHBORS = [[1,0], [-1,0], [0,1], [0,-1]]

      def load(players, data)
        board = self.new

        data['source'].each do |location, stack|
          stack.each do |insect,player|
            player = players[player]
            insect = Insect.const_get(insect).new(player)
            player.insects << insect

            board.source[location] ||= Stack.new(*location)
            board.source[location] << insect
            insect.stack = board.source[location]
          end
        end

        board.map {|k,_| k }.each do |location|
          Board.neighbors(*location).each do |neighbor|
            board.source[neighbor] ||= Stack.new(*neighbor)
          end
        end

        board
      end

      def neighbors(x, y)
        offset = 1 - 2 * (y % 2) # the offset in the x-axis depends on the row
        neighbors = (NEIGHBORS + [[offset,1],[offset,-1]]).map {|i,j| [x+i, y+j] }
        if y % 2 == 1
          neighbors[2], neighbors[4] = neighbors[4], neighbors[2] 
          neighbors[3], neighbors[5] = neighbors[5], neighbors[3] 
        end
        neighbors
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

    def initialize(source=nil)
      @source = source || { [0,0] => Stack.new(0,0) }
    end

    def to_json(*a)
      source = @source.reject {|_,v| v.empty? }.map do |k,v|
        [k, v.map {|insect| [insect.class.name.split('::').last,
                             (insect.player.current_player?) ? 0 : 1 ] }]
      end

      { :source => source }.to_json(*a)
    end

    def to_s(&block)
      block ||= lambda {|_,c,l| [c,l]}

      # remapping the source to be indexed by coordinates
      rows = Hash.new {|h,k| h[k] = Hash.new } 

      # Get a row-by-row hash of the board
      self.each do |location,stack|
        insect = stack.top
        color = (insect.nil?) ? 37 : (insect.player.current_player?) ? 32 : 31
        letter = (insect.nil?) ? 'E' : insect.class.to_s.split('::').last[0].chr
        color,letter = block.call(stack, color, letter)
        rows[location[1]][location[0]] = "\e[#{color}m#{letter}\e[0m"
      end

      min_x = self.min_x
      output = rows.sort_by {|k,_| k }.reverse.inject('') do |n,(i,row)|
        # Fill in the empty spaces
        row = Array.new(row.keys.max - min_x + 1) {|j| row[j+min_x] or ' ' }

        n << ' ' if i % 2 == 0 # offset for even rows
        n << row.join(' ') << "\n"
      end

      output.chomp
    end

    def empty_spaces; self.select {|_,v| v.empty? }.map {|k,_| k }; end
    def insects; self.reject {|_,v| v.empty? }.map {|_,v| v.top }; end

    def [](*location); self.source[location].top; end

    def []=(*location)
      insect = location.pop
      self.source[location] ||= Stack.new(*location)
      self.source[location] << insect
      insect.stack = self.source[location]

      # Add empty stacks as necesssary
      Board.neighbors(*location).each do |neighbor|
        self.source[neighbor] ||= Stack.new(*neighbor)
      end
    end

    def can_slide?(a, b)
      return false unless self.source[b].empty?
      return false unless Board.neighbors(*a).include?(b)

      not (Board.neighbors(*a) & Board.neighbors(*b)).all? do |neighbor|
        not self.source[neighbor].empty? rescue false
      end
    end

    def delete(insect)
      location = insect.location

      stack = self.source[location]
      stack.delete(insect)

      self.neighbors(*location)[:spaces].each do |space|
        self.source.delete(space) if self.neighbors(*space)[:insects].empty?
      end
    end

    def min_x
      self.keys.map(&:first).min
    end

    def neighbors(*location)
      neighbors = Board.neighbors(*location).map do |location|
        [location, self.source[location]]
      end
      spaces,insects = neighbors.select {|_,stack| stack }.partition {|_,stack| stack.empty? }
      { :spaces => spaces.map {|k,_| k }, :insects => insects.map {|_,v| v.top } }
    end
  end
end
