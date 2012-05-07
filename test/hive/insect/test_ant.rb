require 'test_helper'

class TestAnt < HiveTestCase
  def setup
    super

    self.setup_game_mock
  end

  def test_moves_around_edge_of_hive
    board = Board.load(@alice => {Queen:[[1,1]], Beetle:[[2,-1]], Ant:[[1,-2]]},
                       @bob   => {Grasshopper:[[0,0]], Queen:[[2,0]], Beetle:[[1,-1]]})
    @game.expect :board, board

    ant = board[1,-2]
    ant.valid_moves.must_equal [[-1,0], [0,-2], [0,-1], [0, 1], [0, 2], [1, 2], [2, -2], [2, 1], [3, -1], [3, 0], [3, 1]]
  end
end
