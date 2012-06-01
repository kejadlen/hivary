require 'test_helper'

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
    @game.current_player = 0
    refute @alice.current_player?

    @game.current_player = @alice
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

  def test_validate_action
    @game.players = []
    @alice.join_game(@game)

    assert_raises(GameNotStarted) { @alice.validate_action }

    @game.turn = 0
    @game.players = [@bob, @alice]

    assert_raises(InvalidTurn) { @alice.validate_action }
  end

  def test_move_sends_correct_action_to_insect
    insect = MiniTest::Mock.new
    @game.current_player = @alice
    @game.players = [@alice, @bob]
    @game.turn = 0

    insect.expect :played?, false
    insect.expect :send, nil, [:play, [0,0]]
    @alice.move(insect, [0,0])

    insect.expect :played?, true
    insect.expect :send, nil, [:move, [0,0]]
    @alice.move(insect, [0,0])

    insect.verify
  end

  def test_move_increments_turn
    insect = MiniTest::Mock.new
    @game.board = Board.new
    @game.current_player = @alice
    @game.players = [@alice, @bob]
    @game.turn = 0

    @bob.insects << Insect::Base.new(@bob)

    insect.expect :played?, false
    insect.expect :send, nil, [:play, [0,0]]
    @alice.move(insect, [0,0])

    assert_equal 1, @game.turn
    assert_equal [@bob, @alice], @game.players
  end

  def test_skip_turn_with_no_moves
    insect = MiniTest::Mock.new
    @game.board = Board.new
    @game.current_player = @alice
    @game.players = [@alice, @bob]
    @game.turn = 0

    insect.expect :played?, false
    insect.expect :send, nil, [:play, [0,0]]
    @alice.move(insect, [0,0])

    assert_equal [@alice, @bob], @game.players
  end
end
