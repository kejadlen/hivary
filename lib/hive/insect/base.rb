require 'json'

require_relative '../hive'

module Hive
  class InvalidLocation < HiveError; end
  class QueenNotPlayed < HiveError; end
  class UnderAnotherInsect < HiveError; end
  class OneHiveError < HiveError; end

  module Insect
    class Base
      attr_accessor :player, :stack

      def initialize(player, stack=nil)
        @stack = stack
        @player = player
      end
      
      def to_json(*a)
        { klass:self.class.name.split('::').last, location:self.location }.to_json(*a)
      end
      
      def to_s; "<#{self.class.to_s.split('::').last}#{self.location}>"; end

      def board; self.player.board; end
      def breaks_hive?; not Board.one_hive?(self.board.insects.map(&:location) - [self.location]); end
      def game; self.player.game; end
      def location; self.stack.location rescue nil; end
      def played?; !!self.stack; end

      def neighbors; self.board.neighbors(*self.location); end

      def on_top?
        stack = self.board.source[self.location]
        stack.top == self and stack.size > 1
      end

      def validate_placement
        raise InvalidInsect if self.played?
        raise QueenNotPlayed if self.game.turn / 2 == 3 and not self.player.queen.played? and not Queen === self
      end

      def can_play?
        self.validate_placement rescue return false
        true
      end

      def valid_placements
        spaces = self.board.empty_spaces

        return spaces if self.game.turn == 1

        spaces.reject do |location|
          neighbors = Board.neighbors(*location).map {|neighbor| self.board[*neighbor] rescue nil }.compact
          neighbors.any? {|neighbor| neighbor.player != self.player }
        end
      end

      def play(location)
        self.validate_placement
        raise InvalidLocation unless self.valid_placements.include?(location)

        self.board[*location] = self
      end

      def validate_move
        raise InvalidInsect unless self.played?
        raise QueenNotPlayed unless self.player.queen.played?
        raise UnderAnotherInsect unless self.stack.top == self
        raise OneHiveError if self.breaks_hive?
      end

      def can_move?
        self.validate_move rescue return false
        true
      end

      def valid_moves
        self.neighbors[:spaces].select do |space|
          self.board.neighbors(*space)[:insects].uniq != [self] and
            self.board.can_slide?(self.location, space)
        end
      end

      def move(location)
        self.validate_move
        raise InvalidLocation, 'Invalid location' unless self.valid_moves.include?(location)

        self.board.delete(self)
        self.board[*location] = self
      end
    end
  end
end
