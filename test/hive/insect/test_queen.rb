require 'test_helper'

class TestQueen < HiveTestCase
  def setup
    super

    self.setup_game_mock

    @queen = Insect::Queen.new(@alice)
    @alice.insects << @queen
  end

  def test_cant_place_first
    (0..1).each do |turn|
      @game.expect :turn, turn
      assert_raises(IllegalOperation) { @queen.move([0,0]) }
    end
  end

  def test_can_play_on_turns_2_and_3
    board = Board.new
    @game.expect :board, board

    (2..5).each do |turn|
      @game.expect :turn, turn

      insect = Insect::Base.new(@alice)
      insect.move(insect.valid_placements.sample)

      refute_empty @queen.valid_placements
    end
  end

  def test_must_be_played_by_turn_4
    board = Board.new
    @game.expect :board, board

    insect = Insect::Base.new(@alice)

    (6..7).each do |turn|
      @game.expect :turn, turn

      assert_raises(IllegalOperation) { insect.move(insect.valid_placements.sample) }

      refute_empty @queen.valid_placements
    end
  end

  def test_must_be_played_for_other_insects_to_move
    board = Board.load(@alice => {Base:[[0,0]]},
                       @bob => {})
    @game.expect :board, board
    @game.expect :turn, 2

    ant = board[0,0]

    assert_raises(IllegalOperation) { ant.move([1,0]) }

    @queen.move([1,0])

    ant.move([1,1])
  end

  def test_moves_one_tile
    board = Board.load(@alice => {Queen:[[0,0]], Ant:[[1,1]],
                                  Spider:[[2,1]], Grasshopper:[[0,-1]],
                                  Beetle:[[2,-1]]},
                       @bob   => {Spider:[[1,2]], Beetle:[[2,0]],
                                  Grasshopper:[[0,-2]], Ant:[[1,-2]],
                                  Queen:[[2,-2]]})
    @game.expect :board, board

    queen = board[0,0]
    assert_equal [[-1,0], [0,1], [1,-1], [1,0]], queen.valid_moves
  end

  def test_cant_move_off_the_hive
    board = Board.load(@alice => {Spider:[[0,0]], Ant:[[1,-1]], Queen:[[1,0]]},
                       @bob   => {Queen:[[1,-2]], Grasshopper:[[2,-2]]})
    @game.expect :board, board
    @game.expect :turn, 2

    queen = board[1,0]
    assert_equal [[1,1], [2,-1]], queen.valid_moves
  end
end
