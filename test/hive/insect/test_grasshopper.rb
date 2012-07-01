require 'test_helper'

class TestGrasshopper < HiveTestCase
  def test_jumps_in_straight_lines
    @game.board = @board

    grasshopper = @board[0,0]
    grasshopper.valid_moves.must_equal [[-1,2], [1,-2], [3,0]]
  end
end
