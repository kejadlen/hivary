require 'hive/insect/base'

module Hive
  module Insect
    class Grasshopper < Base
      def valid_moves
        neighbors = (0..5).zip(Board.neighbors(*self.location))
        neighbors = neighbors.reject {|_,location| self.board[*location].nil? }
        neighbors.map do |direction,location|
          location = Board.neighbors(*location)[direction] while self.board[*location]
          location
        end
      end
    end
  end
end
