require_relative '../tile'

module Hive
  module Insect
    class Base < Tile
      attr_accessor :player

      def played?; !!self.location; end

      def initialize(player, location=nil)
        super(location)
        @player = player
      end
    end
  end
end
