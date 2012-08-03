require 'test_helper'

class TestLadybug < HiveTestCase
  def test_move
    ladybug = @board[1,-1]
    assert_equal [[-1, 0], [-1, 1], [-1, 2], [0, -1], [1, 1], [1, 2], [2, -1], [2, 0], [2, 2], [3, 1]], ladybug.valid_moves.sort
  end
end
