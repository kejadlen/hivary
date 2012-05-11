require_relative 'base'

require_relative 'climber'

module Hive
  module Insect
    class Beetle < Base
      include Climber

      def valid_moves
        return super if self.on_top?

        neighbors = self.neighbors
        spaces = neighbors[:spaces].select do |space|
          self.board.can_slide?(*[self, space].map(&:location)) and
            space.neighbors[:insects] != [self]
        end
        spaces.map(&:location) + neighbors[:insects].map(&:location)
      end
    end
  end
end
