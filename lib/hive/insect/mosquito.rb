require 'set'

require_relative 'base'

module Hive
  module Insect
    class Mosquito < Base
      include Climber

      def valid_moves
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
