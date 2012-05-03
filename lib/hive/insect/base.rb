require 'set'

require_relative '../tile'

module Hive
  module Insect
    class Base < Tile
      attr_accessor :player

      def board; self.player.board; end
      def empty_space?; false; end
      def game; self.player.game; end

      def initialize(player, location=nil)
        super(location)
        @player = player
      end

      def one_hive?
        hive = Set[self]
        queue = Set[self.neighbors[:insects].first]

        until queue.empty?
          insect = queue.first
          queue.delete(insect)

          neighbors = insect.neighbors[:insects].reject do |neighbor|
            hive.include?(neighbor)
          end

          hive << insect
          queue.merge(neighbors)
        end

        hive.length != self.board.insects.length
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
          raise IllegalOperation, 'Queen has not been played' unless self.player.queen.played?
          raise IllegalOperation, 'Invalid location' unless self.valid_moves.include?(location)
        else
          raise IllegalOperation, "Can't place queen with first move" if self.game.turn / 2 == 0 and Queen === self
          raise IllegalOperation, 'Queen must be played by the fourth turn' if self.game.turn / 2 == 3 and not self.player.queen.played? and not Queen === self
          raise IllegalOperation, 'Invalid location' unless self.valid_placements.include?(location)
        end

        # remove disconnected empty tiles
        spaces = self.neighbors[:spaces]
        spaces.select! {|space| space.neighbors[:insects] == [self] }
        spaces.each {|space| self.board.tiles.delete(self.location) }

        self.board.tiles.delete(self)
        self.board[*location] = self
      end
    end
  end
end
