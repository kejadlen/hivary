require 'test_helper'

# class MiniTest::Mock
  # attr_reader :actual_calls, :expected_calls
# end

class TestPlayer < HiveTestCase
  def setup
    super

    self.setup_game_mock
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
    @game.players = []

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

    @game.players = players
    @game.turn = 2

    @game.expect :current_player, @alice
    insect.expect :move, nil, [[0,0]]
    insect.expect :player, @alice
    @alice.move(insect, [0,0])
    assert_equal [@bob, @alice], players
    assert_equal 3, @game.turn
    @game.verify
    insect.verify
    
    @game.expect :current_player, @alice
    insect.expect :move, nil, [[1,0]]
    insect.expect :player, @alice
    @alice.move(insect, [1,0])
    assert_equal [@alice, @bob], players
    assert_equal 4, @game.turn
    @game.verify
    insect.verify
  end

  def test_skip_turn_with_no_moves
  end
end
