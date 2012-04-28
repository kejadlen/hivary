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
    assert_equal Game::StartInsects, @game.insects
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

  def test_load
  end
end
