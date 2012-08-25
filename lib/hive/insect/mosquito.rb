require 'set'

require_relative 'base'

module Hive
  module Insect
    class Mosquito < Base
      def validate_move
        super
      rescue OneHiveError
        raise unless self.on_top?
      end

      def valid_moves
        return Board.neighbors(*self.location) if self.on_top?
        
        extra_spaces = self.neighbors[:spaces].select do |space|
          self.board.neighbors(*space)[:insects] == [self]
        end

        self.board.source.delete(self.location)

        neighbors = Set[*self.neighbors[:insects]].map(&:class)
        moves = Set.new

        neighbors.each do |klass|
          next if klass == self.class

          insect = klass.new(self.player, Stack.new(*self.location))
          moves.merge(*Set[insect.valid_moves])
        end

        self.board[*self.location] = self

        moves - extra_spaces
      end
    end
  end
end
