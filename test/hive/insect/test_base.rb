require 'test_helper'

class TestBase < HiveTestCase
  def setup
    super

    @insect = Insect::Base.new(@alice)
  end

  def test_init
    assert_equal @alice, @insect.player
    assert_nil @insect.location
  end

  def test_played
    refute @insect.played?

    @insect.location = [0,0]

    assert @insect.played?
  end

  def test_can_place_on_second_turn
    game = Game.load({@alice => {},
                      @bob => {Base:[[0,0]]}},
                      turn:1)
    assert_equal Board.neighbors(0,0), @insect.valid_placements
  end

  def test_valid_placements
    game = MiniTest::Mock.new
    @alice.game = game
    game.expect :board, Board.load(@alice => {Base:[[0,0]]},
                                   @bob => {Base:[[1,0]]})
    game.expect :turn, 2
    assert_equal [[-1,0], [0,-1], [0,1]], @insect.valid_placements
  end

  def test_invalid_placement
    game = MiniTest::Mock.new
    @alice.game = game
    game.expect :board, Board.load(@alice => {Base:[[0,0]]},
                                   @bob => {Base:[[1,0]]})
    game.expect :turn, 2
    assert_raises(IllegalOperation) { @insect.move([2,0]) }

    @alice.insects << Insect::Queen.new(@alice)
    game.expect :turn, 6
    assert_raises(IllegalOperation) { @insect.move([0,1]) }
  end

  def test_valid_moves
    game = MiniTest::Mock.new
    @alice.game = game
    @bob.game = game
    board = Board.load(@alice => {Base:[[0,0]]},
                       @bob => {Base:[[1,0]]})
    game.expect :board, board
    game.expect :current_player, @alice

    assert_equal [[1,-1], [1,1]], board[0,0].valid_moves
  end

  def test_invalid_moves
    board = Board.load(@alice => {Base:[[0,0]]},
                       @bob => {Base:[[1,0]]})
    game = MiniTest::Mock.new
    game.expect :board, board
    @alice.game = game

    assert board[0,0].played?
    assert_raises(IllegalOperation) { board[0,0].move([2,2]) }

    @alice.insects << Insect::Queen.new(@alice)
    assert_raises(IllegalOperation) { board[0,0].move([1,1]) }
  end

  def test_unplaced_move
    game = MiniTest::Mock.new
    @alice.game = game
    board = Board.load(@alice => {Base:[[0,0]]},
                       @bob => {Base:[[1,0]]})
    game.expect :board, board
    game.expect :turn, 2
    @insect.move([0,-1])
    assert_equal @insect, board[0,-1]
  end

  def test_played_move
  end
end
