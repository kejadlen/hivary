require 'test_helper'

class TestGame < HiveTestCase
  def setup
    super

    @game = Game.new
  end

  def test_init
    assert_equal [], @game.players
    refute_nil @game.board
    assert_equal nil, @game.turn
  end

  def test_start
    @game.players = Array.new(2) { MiniTest::Mock.new }
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
    assert_equal @game.current_player, @alice

    @game.players = [@bob, @alice]
    assert_equal @game.current_player, @bob
  end

  def test_load
    game = Game.load({@alice => {Spider:[[0,0]]},
                      @bob => {Ant:[[0,1]]}},
                     turn:5)
    assert_equal [@alice, @bob], game.players
    assert_equal 5, game.turn
  end
end
