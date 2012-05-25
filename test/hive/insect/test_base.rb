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
    @game.turn = 1
    @game.board = board

    refute_empty @insect.valid_placements

    board = Board.load(@alice => {Base:[[1,1]]},
                       @bob   => {Base:[[0,0]]})
    @game.turn = 2
    @game.board = board

    assert_equal [[0,2], [1,2], [2,1]], @insect.valid_placements
  end

  def test_can_play_into_surrounded_space
    board = Board.load(@alice => {Spider:Board.neighbors(0,0)},
                       @bob => {})
    @game.turn = 2
    @game.board = board

    assert_includes Insect::Spider.new(@alice).valid_placements, [0,0]
    refute_includes Insect::Spider.new(@bob).valid_placements, [0,0]
  end

  def test_valid_placements
    @game.board = Board.load(@alice => {Base:[[0,0]]},
                             @bob => {Base:[[1,0]]})
    @game.turn = 2
    assert_equal [[-1,0], [0,-1], [0,1]], @insect.valid_placements
  end

  def test_invalid_placement
    @game.board = Board.load(@alice => {Base:[[0,0]]},
                             @bob => {Base:[[1,0]]})
    @game.current_player = @alice
    @alice.insects << Insect::Queen.new(@alice)

    @game.turn = 6
    assert_raises(QueenNotPlayed) { @insect.play([0,1]) }

    @game.turn = 2
    assert_raises(InvalidLocation) { @insect.play([2,0]) }
  end

  def test_valid_moves
    board = Board.load(@alice => {Base:[[0,0]]},
                       @bob => {Base:[[1,0]]})
    @game.board = board
    @game.expect :current_player, @alice

    assert_equal [[1,-1], [1,1]], board[0,0].valid_moves
  end

  def test_invalid_moves
    board = Board.load(@alice => {Base:[[0,0]]},
                       @bob => {Base:[[1,0]]})
    @game.board = board
    @game.current_player = @alice
    @game.turn = 0
    @alice.insects << Insect::Queen.new(@alice)

    @game.expect :started?, true
    assert board[0,0].played?
    e = assert_raises(QueenNotPlayed) { board[0,0].move([1,1]) }

    @game.expect :started?, true
    board[2,0] = @alice.queen
    assert_raises(InvalidLocation) { board[0,0].move([2,2]) }
  end

  def test_cant_move_even_if_hive_is_relinked
    board = Board.load(@alice => {Ant:[[0,-1]], Beetle:[[2,-1]], Queen:[[0,-2]], Grasshopper:[[1,-3]]},
                       @bob   => {Spider:[[0,0]], Beetle:[[1,0]]})
    @game.expect :current_player, @alice
    @game.board = board

    assert_raises(IllegalOperation) { @alice.queen.validate_move }
  end

  def test_freedom_to_move_in
  end

  def test_freedom_to_move_out
    board = Board.load(@alice => {Queen:[[0,0]], Ant:[[1,0]]},
                       @bob   => {Beetle:[[1,1]], Queen:[[2,1]], Spider:[[2,0]], Ant:[[1,-1]]})
    @game.board = board
    @game.current_player = @alice
    @game.turn = 0

    ant = board[1,0]
    assert_raises(InvalidLocation) { ant.move([2,-1]) }

    board[1,-1] = EmptySpace.new(board, [1,-1])
    ant.move([2,-1])

    assert board[1,0].empty_space?
    assert_equal ant, board[2,-1]
  end

  def test_play
    board = Board.load(@alice => { Base:[[0,0]] },
                       @bob =>  { Base:[[1,0]] })
    @game.board = board
    @game.current_player = @alice
    @game.turn = 2
    @insect.play([0,-1])
    assert_equal @insect, board[0,-1]
  end
end
