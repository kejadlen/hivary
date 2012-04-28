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
    end
  end
end
