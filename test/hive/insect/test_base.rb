require 'test_helper'

class TestBase < HiveTestCase
  def setup
    super

    self.setup_game_mock

    @insect = Insect::Base.new(@alice)
  end

  def test_init
    assert_equal @alice, @insect.player
    assert_nil @insect.location
  end

  def test_can_play_next_to_opponent_on_second_turn
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

  def test_can_play_into_surrounded_space
    board = Board.load(@alice => {Spider:Board.neighbors(0,0)},
                       @bob => {})
    @game.expect :turn, 2
    @game.expect :board, board

    assert_includes Insect::Spider.new(@alice).valid_placements, [0,0]
    refute_includes Insect::Spider.new(@bob).valid_placements, [0,0]
  end

  def test_valid_placements
    @game.expect :board, Board.load(@alice => {Base:[[0,0]]},
                                    @bob => {Base:[[1,0]]})
    @game.expect :turn, 2
    assert_equal [[-1,0], [0,-1], [0,1]], @insect.valid_placements
  end

  def test_cant_place_queen_first
    @game.expect :board, Board.load(@alice => {Base:[[0,0]]},
                                    @bob => {Base:[[1,0]]})
    @alice.insects << Insect::Queen.new(@alice)

    (0..1).each do |turn|
      @game.expect :turn, turn
      e = assert_raises(IllegalOperation) { @alice.queen.move([0,1]) }
      assert_match /queen/, e.message
      assert_match /first/, e.message
    end
  end

  def test_invalid_placement
    @game.expect :board, Board.load(@alice => {Base:[[0,0]]},
                                    @bob => {Base:[[1,0]]})
    @alice.insects << Insect::Queen.new(@alice)

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

    board[2,0] = @alice.queen
    e = assert_raises(IllegalOperation) { board[0,0].move([2,2]) }
    assert_match /invalid location/i, e.message
  end

  def test_cant_move_even_if_hive_is_relinked
    board = Board.load(@alice => {Ant:[[0,-1]], Beetle:[[2,-1]], Queen:[[0,-2]], Grasshopper:[[1,-3]]},
                       @bob   => {Spider:[[0,0]], Beetle:[[1,0]]})
    @game.expect :current_player, @alice
    @game.expect :board, board

    e = assert_raises(IllegalOperation) { @alice.queen.validate_move([1,-2]) }
    assert_match /break/, e.message
    assert_match /hive/, e.message
  end

  def test_freedom_to_move_in
  end

  def test_freedom_to_move_out
    board = Board.load(@alice => {Queen:[[0,0]], Ant:[[1,0]]},
                       @bob   => {Beetle:[[1,1]], Queen:[[2,1]], Spider:[[2,0]], Ant:[[1,-1]]})
    @game.expect :board, board

    ant = board[1,0]
    e = assert_raises(IllegalOperation) { ant.validate_move([2,-1]) }

    board[1,-1] = EmptySpace.new(board, [1,-1])
    ant.move([2,-1])

    assert board[1,0].empty_space?
    assert_equal ant, board[2,-1]
  end

  def test_move
    board = Board.load(@alice => {Base:[[0,0]]},
                       @bob => {Base:[[1,0]]})
    @game.expect :board, board
    @game.expect :turn, 2
    @insect.move([0,-1])
    assert_equal @insect, board[0,-1]
  end
end
