require_relative '../hive'
require_relative '../tile'

module Hive
  module Insect
    class Insect < Tile
      def board; self.player.game.board; end
      def game; self.player.game; end
      def played?; !!self.board.tiles.value?(self); end

      attr_reader :player

      def initialize(player)
        @player = player
      end

      def legal_moves; []; end

      def move(location)
        raise IllegalMove, "Can't move an insect that's not played" unless self.played?
        raise IllegalMove, "Queen has not been played yet" unless self.player.queen.played?
        raise IllegalMove, "Moving #{self} would break the hive" if self.board.one_hive?(self)
      end

      def place(location)
        raise IllegalMove, "Can't place an insect that's already been played" if self.played?

        tile = self.board[*location]
        raise IllegalMove, "#{location} not attached to the hive" unless tile
        raise IllegalMove, "Can't place an insect on top of another insect" unless tile.empty_space?

        if self.board.neighbors(*location)[:insects].any? {|tile| tile.player != self.player } and self.game.turn != 1
          raise IllegalMove, "Can't place an insect next to an opponent's insect"
        end

        self.board[*location] = self
        Board.neighbors(*location).each do |location|
          self.board[*location] = EmptySpace.new(self.board) if self.board[*location].nil?
        end
      end

      def to_s
        "#{super}(#{self.player.name})"
      end
    end
  end
end
