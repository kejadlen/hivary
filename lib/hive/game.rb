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
        players = data.keys
        opts[:expansions] ||= []

        game = self.new(players, Board.load(data), opts[:turn], opts[:expansions])

        players.each do |player|
          player.game = game
          game.insects.each do |klass,n|
            insects = data[player][klass.to_s.split('::').last.to_sym]
            n -= insects.length rescue 0
            n.times { player.insects << klass.new(player) }
          end
        end

        game
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

      @insects[Insect::Ladybug] = 1 if expansions.include?(:ladybug)
      @insects[Insect::Mosquito] = 1 if expansions.include?(:mosquito)
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
