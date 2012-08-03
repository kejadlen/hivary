require_relative 'base'

module Hive
  module Insect
    class Beetle < Base
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

        neighbors = self.neighbors
        spaces = neighbors[:spaces].select do |space|
          self.board.can_slide?(self.location, space) and
            self.board.neighbors(*space)[:insects] != [self]
        end

        extra_spaces.each {|space| self.board.source[space] = Stack.new(*space) }

        spaces + neighbors[:insects].map(&:location)
      end
    end
  end
end
