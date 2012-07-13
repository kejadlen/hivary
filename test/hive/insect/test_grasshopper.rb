require 'test_helper'

class TestGrasshopper < HiveTestCase
  def test_jumps_in_straight_lines
    grasshopper = @board[0,0]
     assert_equal [[-1,2], [1,-2], [3,0]], grasshopper.valid_moves.sort
  end

  def test_bug
    assert_equal [[-2,0], [-1,-2], [1,-2], [2,0]], @board[0,0].valid_moves.sort
  end
end
