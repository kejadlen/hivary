require_relative 'base'

module Hive
  module Insect
    class Grasshopper < Base
      def valid_moves
        neighbors = Board.neighbors(*self.location).map.with_index {|location,i| [i, location] }
        neighbors = neighbors.reject {|_,location| self.board[*location].nil? }
        neighbors.map do |direction,location|
          location = Board.neighbors(*location)[direction] while self.board[*location]
          location
        end
      end
    end
  end
end
