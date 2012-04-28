require_relative 'hive'

module Hive
  class Player
    def board; self.game.board; end
    def current_player?; self.game.current_player == self; end
    def queen; self.insects.find {|insect| Insect::Queen === insect }; end

    attr_accessor :game, :insects
    attr_reader :name

    def initialize(name)
      @name = name
      @insects = []
    end

    def join(game)
      raise IllegalMove, "#{self} already joined #{game}" unless self.game.nil?

      game.players << self
      self.game = game
    end

    def move(insect, location)
      raise IllegalMove, "#{game} has not started yet" if self.game.turn.nil?
      raise IllegalMove, "It is not #{self}'s turn" if self.game.current_player != self
      raise IllegalMove, "#{insect} does not belong to #{self}" if insect.player != self
      raise IllegalMove, "Queen must be placed in the first four moves" if self.game.turn / 2 == 3 and not self.queen.played?

      if insect.played?
        insect.move(location)
      else
        insect.place(location)
      end

      # TODO: check to see if the other player can move

      self.game.players << self.game.players.shift
      self.game.turn += 1
    end
  end
end
