require 'test_helper'

class TestMosquito < HiveTestCase
  def test_valid_moves
    mosquito = @board[1,-1]
    assert_equal [[0,-1], [0,0], [0,1], [1,0], [2,-1], [3,0]], mosquito.valid_moves.sort
  end

  def test_doesnt_copy_mosquitos
    mosquito = @board[0,-2]
    assert_empty mosquito.valid_moves
  end
end
