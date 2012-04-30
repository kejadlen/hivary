require_relative '../tile'

module Hive
  module Insect
    class Base < Tile
      attr_accessor :player

      def board; self.player.board; end
      def empty_space?; false; end
      def game; self.player.game; end
      def played?; !!self.location; end

      def initialize(player, location=nil)
        super(location)
        @player = player
      end

      def valid_placements
        return self.board.empty_spaces if self.game.turn == 1

        self.board.empty_spaces.reject do |location|
          neighbors = self.board[*location].neighbors[:insects]
          neighbors.any? {|neighbor| neighbor.player != self.player }
        end
      end

      def valid_moves
        moves = self.neighbors[:spaces].reject do |neighbor|
          neighbor.neighbors[:insects].uniq == [self]
        end
        moves.map(&:location)
      end

      def move(location)
        if self.played?
          raise IllegalOperation, '' unless self.valid_moves.include?(location)
          raise IllegalOperation, '' unless self.player.queen.played?
        else
          raise IllegalOperation, '' unless self.valid_placements.include?(location)
          raise IllegalOperation, '' if self.game.turn / 3 == 2 and not self.player.queen.played? and not Queen === self
        end

        self.location = location
        self.board.tiles.delete(self)
        self.board[*location] = self
      end
    end
  end
end
