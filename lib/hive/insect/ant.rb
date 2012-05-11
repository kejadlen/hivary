require 'set'

require_relative 'base'

module Hive
  module Insect
    class Ant < Base
      def valid_moves
        extra_spaces = self.neighbors[:spaces].select do |space|
          space.neighbors[:insects] == [self]
        end
        extra_spaces.each {|space| self.board.delete(space) }

        queue = Set[*super.map {|location| self.board[*location] }]
        moves = Set.new

        until queue.empty?
          move = queue.first
          queue.delete(move)

          spaces = move.neighbors[:spaces].select do |space|
            not moves.include?(space) and self.board.can_slide?(move.location, space.location)
          end
          queue.merge(spaces)

          moves << move
        end

        extra_spaces.each {|space| self.board[*space.location] = space }

        moves.map(&:location).sort
      end
    end
  end
end
