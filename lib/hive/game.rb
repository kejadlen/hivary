require 'set'

require_relative '../hive'
require_relative 'board'
require_relative 'insect/all'

module Hive
  class Game
    StartInsects = { Insect::Queen => 1,
                     Insect::Spider => 2,
                     Insect::Beetle => 2,
                     Insect::Grasshopper => 3,
                     Insect::Ant => 3 }

    class << self
      def load(data, opts={})
        opts[:expansions] ||= []
        self.new(data.keys, Board.load(data), opts[:turn], opts[:expansions])
      end
    end

    attr_reader :board, :insects
    attr_accessor :players, :turn

    def current_player; self.players.first; end

    def initialize(players=[], board=nil, turn=nil, expansions=[])
      @insects = StartInsects.dup

      @players = players
      @board = board || Board.new
      @turn = turn

      @insects << Insect::Ladybug if expansions.include?(:ladybug)
      @insects << Insect::Mosquito if expansions.include?(:mosquito)
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
