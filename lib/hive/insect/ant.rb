require 'set'

require_relative 'base'

module Hive
  module Insect
    class Ant < Base
      def valid_moves
        extra_spaces = self.neighbors[:spaces].select do |space|
          self.board.neighbors(*space)[:insects] == [self]
        end
        extra_spaces.each {|space| self.board.source.delete(space) }

        queue = Set[*super]
        moves = Set.new

        until queue.empty?
          move = queue.first
          queue.delete(move)

          spaces = self.board.neighbors(*move)[:spaces].select do |space|
            not moves.include?(space) and self.board.can_slide?(move, space)
          end
          queue.merge(spaces)

          moves << move
        end

        extra_spaces.each {|space| self.board.source[space] = Stack.new(*space) }

        moves.sort
      end
    end
  end
end
