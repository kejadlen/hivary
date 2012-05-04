require 'test_helper'

class TestPlayer < HiveTestCase
  def setup
    super

    @game = MiniTest::Mock.new
    @alice.game = @game
  end

  def test_init
    assert_equal 'Alice', @alice.name
    assert_equal [], @alice.insects
  end

  def test_current_player
    @game.expect :current_player, 0
    refute @alice.current_player?

    @game.expect :current_player, @alice
    assert @alice.current_player?
  end

  def test_join_game
    @game.expect :players, []

    @alice.join_game(@game)

    @game.verify

    @game.expect :==, true, [@game]
    assert_equal @game, @alice.game
    assert_equal @game.players, [@alice]
  end

  def test_prepare_insects
    @game.expect :insects, {Insect::Base => 2}
    @alice.game = @game

    @alice.prepare_insects

    assert_equal 2, @alice.insects.length
    assert_equal [Insect::Base, Insect::Base],
                 @alice.insects.map(&:class)
  end

  def test_move
    players = [@alice, @bob]
    insect = MiniTest::Mock.new

    @game.expect :current_player, @alice
    @game.expect :players, players
    @game.expect :turn, 2
    insect.expect :player, @alice

    @game.expect :turn=, 3, [3]
    insect.expect :move, nil, [[0,0]]
    @alice.move(insect, [0,0])
    assert_equal [@bob, @alice], players
    @game.verify
    insect.verify
    
    @game.expect :turn, 3

    @game.expect :turn=, 4, [4]
    insect.expect :move, nil, [[1,0]]
    @alice.move(insect, [1,0])
    assert_equal [@alice, @bob], players
    @game.verify
    insect.verify
  end

  def test_skip_turn_with_no_moves
  end
end
