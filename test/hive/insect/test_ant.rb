require 'test_helper'

class TestAnt < HiveTestCase
  def setup
    super

    self.setup_game_mock
  end

  def test_moves_around_edge_of_hive
    board = Board.load(@alice => {Queen:[[1,1]], Beetle:[[2,-1]], Ant:[[1,-2]]},
                       @bob   => {Grasshopper:[[0,0]], Queen:[[2,0]], Beetle:[[1,-1]]})
    @game.board = board

    ant = board[1,-2]
    assert_equal [[-1,0], [0,-2], [0,-1], [0, 1], [0, 2], [1, 2], [2, -2], [2, 1], [3, -1], [3, 0], [3, 1]], ant.valid_moves

    assert_equal ant, board[1,-2]

    refute_empty board.source[[1,-3]].location
    refute_empty board.source[[2,-3]].location
  end
end
