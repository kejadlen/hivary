require 'test_helper'

class TestBase < HiveTestCase
  def setup
    super

    @game = MiniTest::Mock.new
    [@alice, @bob].each {|player| player.game = @game }

    @insect = Insect::Base.new(@alice)
  end

  def test_init
    assert_equal @alice, @insect.player
    assert_nil @insect.location
  end

  def test_place_next_to_opponent
    board = Board.load(@alice => {},
                       @bob   => {Base:[[0,0]]})
    @game.expect :turn, 1
    @game.expect :board, board

    refute_empty @insect.valid_placements

    board = Board.load(@alice => {Base:[[1,1]]},
                       @bob   => {Base:[[0,0]]})
    @game.expect :turn, 2
    @game.expect :board, board

    assert_equal [[0,2], [1,2], [2,1]], @insect.valid_placements
  end

  def test_valid_placements
    @game.expect :board, Board.load(@alice => {Base:[[0,0]]},
                                    @bob => {Base:[[1,0]]})
    @game.expect :turn, 2
    assert_equal [[-1,0], [0,-1], [0,1]], @insect.valid_placements
  end

  def test_invalid_placement
    @game.expect :board, Board.load(@alice => {Base:[[0,0]]},
                                    @bob => {Base:[[1,0]]})
    @alice.insects << Insect::Queen.new(@alice)

    (0..1).each do |turn|
      @game.expect :turn, turn
      e = assert_raises(IllegalOperation) { @alice.queen.move([0,1]) }
      assert_match /queen/, e.message
      assert_match /first/, e.message
    end

    @game.expect :turn, 6
    e = assert_raises(IllegalOperation) { @insect.move([0,1]) }
    assert_match /queen/i, e.message
    assert_match /four/, e.message
    assert_match /turn/, e.message

    @game.expect :turn, 2
    e = assert_raises(IllegalOperation) { @insect.move([2,0]) }
    assert_match /invalid location/i, e.message
  end

  def test_valid_moves
    board = Board.load(@alice => {Base:[[0,0]]},
                       @bob => {Base:[[1,0]]})
    @game.expect :board, board
    @game.expect :current_player, @alice

    assert_equal [[1,-1], [1,1]], board[0,0].valid_moves
  end

  def test_invalid_moves
    board = Board.load(@alice => {Base:[[0,0]]},
                       @bob => {Base:[[1,0]]})
    @game.expect :board, board
    @alice.insects << Insect::Queen.new(@alice)

    assert board[0,0].played?
    e = assert_raises(IllegalOperation) { board[0,0].move([1,1]) }
    assert_match /queen/i, e.message
    assert_match /played/, e.message

    board[-1,0] = @alice.queen
    e = assert_raises(IllegalOperation) { board[0,0].move([2,2]) }
    assert_match /invalid location/i, e.message
  end

  def test_move
    board = Board.load(@alice => {Base:[[0,0]]},
                       @bob => {Base:[[1,0]]})
    @game.expect :board, board
    @game.expect :current_player, @alice
    @game.expect :turn, 2
    @insect.move([0,-1])
    assert_equal @insect, board[0,-1]
  end
end
