require_relative '../tile'

module Hive
  module Insect
    class Base < Tile
      def initialize(player, location=nil)
        super(location)
        @player = player
      end
    end
  end
end
