require 'test_helper'

class TestSpider < HiveTestCase
  def setup
    super

    self.setup_game_mock
  end

  def test_moves_three_spaces
    board = Board.load(@alice => {Ant:[[0,0]], Queen:[[0,-1]],
                                  Grasshopper:[[1,-2]], Spider:[[2,2]],
                                  Beetle:[[3,-1]]},
                       @bob   => {Beetle:[[1,1]], Grasshopper:[[0,-2]],
                                  Ant:[[2,-2]], Queen:[[3,0]],
                                  Spider:[[3,1]]})
    @game.board = board

    spider = board[2,2]
    spider.valid_moves.must_equal [[0,2], [1,-1], [2,-1], [4,0]]
  end
end
