module Hive
  class Player
    attr_accessor :game
    attr_reader :name, :insects

    def initialize(name)
      @name = name
      @insects = []
    end

    def join_game(game)
      raise IllegalOperation, 'Game already full' unless game.players.length < 2

      self.game = game
      game.players << self
    end

    def prepare_insects
      self.game.insects.each do |klass,n|
        n.times { self.insects << klass.new(self) }
      end
    end

    def move(insect, location)
      raise IllegalOperation, 'Game has not started' if self.game.turn.nil?
      raise IllegalOperation, '' if insect.player != self
      raise IllegalOperation, '' if self.game.current_player != self

      if insect.played?
        insect.move(location)
      else
        insect.place(location)
      end

      # change the current player (only if the other player can move)

      self.game.turn += 1
    end
  end
end
