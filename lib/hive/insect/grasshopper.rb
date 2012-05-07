require_relative 'base'

module Hive
  module Insect
    class Grasshopper < Base
      def valid_moves
        neighbors = Board.neighbors(*self.location).map.with_index {|neighbor,i| [i, self.board[*neighbor]] }
        neighbors = neighbors.reject {|i,neighbor| neighbor.empty_space? }
        neighbors.map do |direction,insect|
          insect = self.board[*Board.neighbors(*insect.location)[direction]] until insect.empty_space?
          insect.location
        end
      end
    end
  end
end
