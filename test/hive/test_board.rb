require 'test_helper'

require 'hive/board'

class TestBoard < HiveTestCase
  def setup
    @board = Board.new
  end

  def test_init
    assert_equal 1, @board.insects.length
    assert_equal EmptySpace, @board[0,0].class
  end
end
