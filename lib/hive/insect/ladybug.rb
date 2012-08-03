require 'set'

require_relative 'base'

module Hive
  module Insect
    class Ladybug < Base
      def valid_moves
        self.board.source.delete(self.location)

        moves = Set[*self.neighbors[:insects]]
        moves = Set[*moves.map {|move| move.neighbors[:insects] }.flatten]
        moves = Set[*moves.map {|move| move.neighbors[:spaces] }.flatten(1)]

        self.board[*self.location] = self

        moves
      end
    end
  end
end
