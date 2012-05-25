require_relative 'base'

module Hive
  module Insect
    class Queen < Base
      def validate_placement
        raise IllegalOperation, "Can't place queen with first move" if self.game.turn / 2 == 0
        super
      end
    end
  end
end
