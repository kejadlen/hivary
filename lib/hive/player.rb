require_relative 'hive'

module Hive
  class GameNotStarted < HiveError; end
  class InvalidInsect < HiveError; end
  class InvalidTurn < HiveError; end
  class GameOver < HiveError; end

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

    def can_move?
      self.insects.any? do |insect|
        not insect.valid_placements.empty? or not insect.valid_moves.empty?
      end
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

    def validate_action
      raise GameNotStarted if self.game.turn.nil?
      raise InvalidTurn unless self.current_player?
      raise GameOver if self.game.over?
    end

    def move(insect, location)
      self.validate_action

      raise InvalidInsect unless insect.player == self

      insect.send((insect.played?) ? :move : :play, location)

      @game.turn += 1

      @game.players << @game.players.shift if @game.players.last.can_move?
    end
  end
end
