require_relative '../hive'

module Hive
  class InvalidLocation < HiveError; end
  class QueenNotPlayed < HiveError; end
  class OneHiveError < HiveError; end

  module Insect
    class Base
      attr_accessor :player, :stack

      def board; self.player.board; end
      def breaks_hive?; not Board.one_hive?(self.board.insects.map(&:location) - [self.location]); end
      def game; self.player.game; end
      def location; self.stack.location rescue nil; end
      def played?; !!self.stack; end

      def initialize(player, stack=nil)
        @stack = stack
        @player = player
      end

      def to_s; "<#{self.class.to_s.split('::').last}#{self.location}>"; end

      def neighbors; self.board.neighbors(*self.location); end

      def on_top?
        stack = self.board.source[self.location]
        stack.top == self and stack.size > 1
      end

      def validate_placement
        raise InvalidInsect if self.played?
        raise QueenNotPlayed if self.game.turn / 2 == 3 and not self.player.queen.played? and not Queen === self
      end

      def valid_placements
        spaces = self.board.empty_spaces

        return spaces if self.game.turn == 1

        spaces.reject do |location|
          neighbors = Board.neighbors(*location).map {|neighbor| self.board[*neighbor] rescue nil }.compact
          # neighbors = self.board[*location].neighbors[:insects]
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
        raise OneHiveError if self.breaks_hive?
      end

      def valid_moves
        self.neighbors[:spaces].select do |space|
          self.board.neighbors(*space)[:insects].uniq != [self] and
            self.board.can_slide?(self.location, space)
        end
      end

      def move(location)
        self.player.validate_action
        self.validate_move
        raise InvalidLocation, 'Invalid location' unless self.valid_moves.include?(location)

        self.board.delete(self)
        self.board[*location] = self

        # TODO: remove extraneous empty tiles
      end
    end
  end
end
