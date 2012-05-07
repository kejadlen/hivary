require 'test_helper'

class TestGrasshopper < HiveTestCase
  def setup
    super

    self.setup_game_mock
  end

  def test_jumps_in_straight_lines
    board = Board.load(@alice => {Grasshopper:[[0,0]], Queen:[[2,0]],
                                  Ant:[[1,2]], Beetle:[[1,-1]],
                                  Spider:[[4,0],[2,1]]},
                       @bob   => {Grasshopper:[[1,0]], Queen:[[0,1]],
                                  Ant:[[0,2]], Beetle:[[3,1]],
                                  Spider:[[4,1],[4,-1]]})
    @game.expect :board, board

    grasshopper = board[0,0]
    grasshopper.valid_moves.must_equal [[-1,2], [1,-2], [3,0]]
  end
end
