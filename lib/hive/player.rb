module Hive
  class Player
    attr_accessor :game
    attr_reader :name, :insects

    def current_player?; self.game.current_player == self; end
    def board; self.game.board; end
    def queen; self.insects.find {|insect| Insect::Queen === insect }; end

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

    def validate_move(insect)
      raise IllegalOperation, 'Game has not started' if self.game.turn.nil?
      raise IllegalOperation, '' if insect.player != self
      raise IllegalOperation, "Not #{player}'s turn" unless self.current_player?
    end

    def move(insect, location)
      self.validate_move(insect)

      insect.move(location)

      # TODO: only change the current player if s/he can move
      self.game.players << self.game.players.shift

      self.game.turn += 1
    end
  end
end
