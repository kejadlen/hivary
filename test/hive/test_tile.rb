require 'test_helper'

class TestTile < HiveTestCase
  def setup
    super

    @tile = Tile.new([0,0])
  end

  def test_neighbors
    board = Board.load(@alice => {Base:[[1,0], [1,-1], [1,1]]},
                       @bob => {Base:[[0,0]]})
    game = MiniTest::Mock.new
    game.expect :board, board
    @bob.game = game
    neighbors = board[0,0].neighbors

    assert_equal 3, neighbors[:spaces].length
    assert_equal [[-1,0], [0,-1], [0,1]], neighbors[:spaces].map(&:location)
    assert_equal 3, neighbors[:insects].length
    assert_equal [[1,-1], [1,0], [1,1]], neighbors[:insects].map(&:location)
  end
end
