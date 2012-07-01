require 'test_helper'

class TestSpider < HiveTestCase
  def test_moves_three_spaces
    @game.board = @board

    spider = @board[2,2]
    spider.valid_moves.must_equal [[0,2], [1,-1], [2,-1], [4,0]]
  end

  def test_needs_freedom_to_move
    @game.board = @board

    spider = @board[0,0]
    assert_empty spider.valid_moves
  end

  def test_edge_cases
    @game.board = @board

    spider = @board[0,0]
    assert_empty spider.valid_moves
  end
end
