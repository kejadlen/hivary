require 'test_helper'

require 'hive/board'
require 'hive/insect/all'

class TestBoard < HiveTestCase
  def setup
    @board = Board.new
  end

  def test_init
    assert_equal 1, @board.tiles.length
    assert_equal EmptySpace, @board[0,0].class
  end

  def test_load
    alice = MiniTest::Mock.new
    bob = MiniTest::Mock.new

    board = Board.load(alice => {Spider:[[0,0]]},
                       bob   => {Ant:[[0,1]]})

    assert_equal Insect::Spider, board[0,0].class
    assert_equal Insect::Ant, board[0,1].class
    assert_equal 10, board.tiles.length
  end

  def test_neighbors
    assert_equal [[-1,0], [0,-1], [0,1], [1,-1], [1,0], [1,1]],
                 Board.neighbors(0,0)
    assert_equal [[-1,0], [-1,1], [-1,2], [0,0], [0,2], [1,1]],
                 Board.neighbors(0,1)
  end

  def test_assignment
    insect = MiniTest::Mock.new
    insect.expect :==, true, [insect]
    insect.expect :empty_space?, false
    @board[1,0] = insect

    assert_equal insect, @board.tiles[[1,0]]
    assert_equal 7, @board.tiles.length
    assert_equal 6, @board.tiles.select {|_,tile| tile.empty_space? }.length
  end
end
