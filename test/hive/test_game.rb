require 'test_helper'

require 'hive'
require 'hive/game'

class TestGame < HiveTestCase
  def setup
    @game = Game.new
    @alice = MiniTest::Mock.new
    @bob = MiniTest::Mock.new
  end

  def test_init
    assert_equal [], @game.players
    refute_nil @game.board
    assert_equal nil, @game.turn
  end

  def test_start
    @game.players = [@alice, @bob]
    @game.players.each do |player|
      player.expect :prepare_insects, nil
    end

    @game.start!

    @game.players.each {|player| player.verify }

    # TODO: test player randomization

    assert_equal 0, @game.turn
  end

  def test_current_player
    @game.players = [@alice, @bob]
    @alice.expect :==, true, [@alice]
    assert_equal @game.current_player, @alice

    @game.players = [@bob, @alice]
    @bob.expect :==, true, [@bob]
    assert_equal @game.current_player, @bob
  end

  def test_load
    game = Game.load({alice:{Spider:[[0,0]]},
                      bob:{Ant:[[0,1]]}},
                     turn:5)
    assert_equal [:alice, :bob], game.players
    assert_equal 5, game.turn
  end
end
