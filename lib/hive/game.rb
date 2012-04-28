require_relative '../hive'
require_relative 'board'

module Hive
  class Game
    StartInsects = { Queen:1,
                     Spider:2,
                     Beetle:2,
                     Grasshopper:3,
                     Ant:3 }

    class << self
      def load
      end
    end

    attr_reader :board, :insects
    attr_accessor :players, :turn

    def initialize(players=[], board=nil, turn=nil, expansions={})
      @insects = StartInsects.dup

      @players = players
      @board = board || Board.new
      @turn = turn
    end

    def start!
      raise IllegalOperation, 'Game has already started' unless self.turn.nil?
      raise IllegalOperation, 'Two players are required to start the game' unless self.players.length == 2

      @players.each do |player|
        player.prepare_insects
      end

      # randomize the starting player
      self.players << self.players.shift if rand(2) == 0

      self.turn = 0
    end
  end
end
