require 'delegate'

require_relative 'stack'
require_relative 'insect/all'

module Hive
  class Board < Delegator
    attr_reader :source
    def __getobj__; @source; end

    class << self
      NEIGHBORS = [[1,0], [-1,0], [0,1], [0,-1]]

      def load(data)
        board = self.new
        board.source.delete([0,0]) # remove the initial empty space

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

    def [](*location); self.source[location].top; end

    def []=(*location, insect)
      self.source[location] ||= Stack.new(*location)
      self.source[location] << insect
      insect.stack = self.source[location]

      # Add empty stacks as necesssary
      Board.neighbors(*location).each do |neighbor|
        self.source[neighbor] ||= Stack.new(*neighbor)
      end
    end

    def initialize
      @source = { [0,0] => Stack.new(0,0) }
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

      # self.source.delete(location) if stack.empty?
    end

    def empty_spaces; self.select {|_,v| v.empty? }.map {|k,_| k }; end
    def insects; self.reject {|_,v| v.empty? }.map {|_,v| v.top }; end

    def neighbors(*location)
      neighbors = Board.neighbors(*location).map do |location|
        [location, self.source[location]]
      end
      spaces,insects = neighbors.select {|_,stack| stack }.partition {|_,stack| stack.empty? }
      { spaces:spaces.map {|k,_| k }, insects:insects.map {|_,v| v.top } }
    end

    def to_s
      min_x = 0 # so each row can be offset correctly
      rows = Hash.new {|h,k| h[k] = Hash.new } # remapping the source to be indexed by coordinates

      # Get a row-by-row hash of the board, storing each tile as a colored letter
      self.source.each do |location,stack|
        insect = stack.top
        min_x = [min_x, location[0]].min

        color = (insect.nil?) ? 37 : (insect.player.current_player?) ? 32 : 31
        letter = (insect.nil?) ? 'E' : insect.class.to_s.split('::').last[0]
        rows[location[1]][location[0]] = "\e[#{color}m#{letter}\e[0m"
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
