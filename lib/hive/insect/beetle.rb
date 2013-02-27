require_relative 'base'
require_relative 'climber'

module Hive
  module Insect
    class Beetle < Base
      include Climber

      def valid_moves
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
