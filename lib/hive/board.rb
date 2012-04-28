require 'set'

require_relative 'insect/all'
require_relative 'tile'

module Hive
  class Board
    NEIGHBORS = [[1,0], [-1,0], [0,1], [0,-1]]
    
    class << self
      def neighbors(x, y)
        offset = 1 - 2 * (y % 2) # the offset in the x-axis depends on the row
        (NEIGHBORS + [[offset,1], [offset,-1]]).map {|i,j| [x+i, y+j] }.sort
      end

      def load(players)
        tiles = players.inject({}) do |h,(player,insects)|
          insects.each do |klass,location|
          end
          h
        end
        self.new(tiles)
      end
    end

    def [](*location); @tiles[location]; end
    def []=(*location, insect); @tiles[location] = insect; end
    def location_of(insect); @tiles.rassoc(insect)[0]; end

    attr_reader :tiles

    def initialize(tiles=nil)
      @tiles = (tiles and not tiles.empty?) ? tiles : { [0,0] => EmptySpace.new(self) }
    end

    def neighbors(*location)
      # location = self.location_of(location[0]) if Tile === location[0].class
      neighbors = Board.neighbors(*location).map {|location| self[*location] }.compact
      spaces,insects = neighbors.partition {|neighbor| neighbor.empty_space? }
      { spaces:spaces, insects:insects }
    end

    # Returns true if moving the insect would break the hive
    def one_hive?(insect)
      return false unless self.tiles.include?(insect)
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
