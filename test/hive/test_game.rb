require 'test_helper'

require 'hive/game'
require 'hive/player'

class TestGame < HiveTestCase
  def setup
    @alice = Player.new('Alice')
    @bob = Player.new('Bob')
    @game = Game.new

    @alice.join(@game)
    @bob.join(@game)
  end

  def test_initialize
    @game.board.wont_equal nil
    @game.turn.must_equal nil
  end

  def test_start_errors
    alice = Player.new('Alice')
    game = Game.new

    game.start!.must_equal nil

    alice.join(game)
    
    game.start!.must_equal nil
  end

  def test_start
    @game.start!

    @game.turn.must_equal 0

    @game.players.each do |player|
      player.insects.each {|insect| insect.played?.must_equal false }
      insects = player.insects.inject(Hash.new {|h,k| h[k] = 0 }) do |hash,insect|
        hash[insect.class] += 1
        hash
      end
      Game::STARTING_INSECTS.each do |insect,num|
        insects[Hive::Insect.const_get(insect)].must_equal num
      end
    end
  end
end
