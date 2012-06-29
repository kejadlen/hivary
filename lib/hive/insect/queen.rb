require_relative 'base'

module Hive
  module Insect
    class Queen < Base
      def validate_placement
        raise IllegalOperation, "Can't place queen with first move" if self.game.turn / 2 == 0
        super
      end

      def valid_placements
        return [] if self.game.turn / 2 == 0

        super
      end

      def surrounded?
        self.location and self.neighbors[:spaces].empty?
      end
    end
  end
end
