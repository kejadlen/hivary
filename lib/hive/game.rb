require 'json'
require 'set'

require 'hive'
require 'hive/board'
require 'hive/insect/all'

module Hive
  class Game
    START_INSECTS = { Insect::Queen => 1,
                      Insect::Spider => 2,
                      Insect::Beetle => 2,
                      Insect::Grasshopper => 3,
                      Insect::Ant => 3 }

    class << self
      def load(data)
        expansions = data['expansions'] || []
        players = data['players'].map {|name| Player.new(name) }
        board = Board.load(players, data['board'])

        game = self.new(players,
                        board,
                        data['turn'],
                        expansions)

        players.each {|player| player.prepare_insects }

        board.each do |_,stack|
          stack.each do |insect|
            insect = insect.player.insects.find {|i| i.class == insect.class }
            insect.player.insects.delete(insect)
          end
        end
        
        game
      end
    end

    def initialize(players=[], board=nil, turn=nil, expansions=[])
      @players = players
      @players.each {|player| player.game = self }

      @board = board || Board.new
      @turn = turn
      @expansions = expansions
    end

    def to_json(*a)
      { :players => self.players.map(&:name),
        :turn => self.turn,
        :board => self.board }.to_json(*a)
    end

    attr_reader :board, :expansions, :players
    attr_accessor :turn

    def current_player; self.players.first; end

    def insects
      insects = START_INSECTS.dup
      insects[Insect::Ladybug] = 1 if expansions.include?(:ladybug)
      insects[Insect::Mosquito] = 1 if expansions.include?(:mosquito)
      insects
    end

    def start
      raise IllegalOperation, 'Game has already started' unless self.turn.nil?
      raise IllegalOperation, 'Two players are required to start the game' unless self.players.length == 2

      @players.each do |player|
        player.prepare_insects
      end

      # randomize the starting player
      self.players << self.players.shift if rand(2) == 0

      self.turn = 0
    end

    def over?
      return false if self.turn.nil?

      @players.any? {|player| player.queen.surrounded? }
    end
  end
end
