require_relative 'board'
require_relative 'insect/all'

module Hive
  class Game
    STARTING_INSECTS = { Queen:1,
                         Spider:2,
                         Beetle:2,
                         Grasshopper:3,
                         Ant:3 }

    attr_reader :board
    attr_accessor :players, :turn

    def current_player; self.players.first; end

    def initialize
      @players = []
      @board = Board.new

      @turn = nil
    end

    def start!
      return nil if self.players.length != 2
      return nil unless self.turn.nil?

      self.players.each do |player|
        STARTING_INSECTS.each do |insect,i|
          player.insects.concat(Array.new(i) { Hive::Insect.const_get(insect).new(player) })
        end
      end

      self.players << self.players.shift if rand(2) == 0 # randomize the starting player
      self.turn = 0
      self
    end
  end
end
