require 'set'

require_relative '../hive'
require_relative '../tile'

module Hive
  class InvalidLocation < HiveError; end
  class QueenNotPlayed < HiveError; end

  module Insect
    class Base < Tile
      attr_accessor :player

      def board; self.player.board; end
      def breaks_hive?; not Board.one_hive?(self.board.insects.map(&:location) - [self.location]); end
      def empty_space?; false; end
      def game; self.player.game; end

      def initialize(player, location=nil)
        super(location)
        @player = player
      end

      def validate_placement
        raise InvalidInsect if self.played?
        raise QueenNotPlayed if self.game.turn / 2 == 3 and not self.player.queen.played? and not Queen === self
      end

      def valid_placements
        spaces = self.board.empty_spaces.map(&:location)

        return spaces if self.game.turn == 1

        spaces.reject do |location|
          neighbors = self.board[*location].neighbors[:insects]
          neighbors.any? {|neighbor| neighbor.player != self.player }
        end
      end

      def play(location)
        self.player.validate_action
        self.validate_placement
        raise InvalidLocation unless self.valid_placements.include?(location)

        self.board[*location] = self
      end
      
      def validate_move
        raise InvalidInsect unless self.played?
        raise QueenNotPlayed unless self.player.queen.played?
        raise IllegalOperation, 'Under another piece' unless self.board.insects.include?(self)
        raise IllegalOperation, 'Moving will break the hive' if self.breaks_hive?
      end

      def valid_moves
        moves = self.neighbors[:spaces].select do |neighbor|
          neighbor.neighbors[:insects].uniq != [self] and self.board.can_slide?(self.location, neighbor.location)
        end
        moves.map(&:location)
      end

      def move(location)
        self.player.validate_action
        self.validate_move
        raise InvalidLocation, 'Invalid location' unless self.valid_moves.include?(location)

        # remove disconnected empty tiles
        spaces = self.neighbors[:spaces]
        spaces.select! {|space| space.neighbors[:insects] == [self] }
        spaces.each {|space| self.board.delete(self) }

        self.board.delete(self)
        self.board[*location] = self
      end
    end
  end
end
