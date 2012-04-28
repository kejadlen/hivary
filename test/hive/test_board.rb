require 'test_helper'

require 'hive/board'

class TestBoard < HiveTestCase
  def setup
    @board = Board.new
  end

  def test_initialize
    @board[0,0].empty_space?.must_equal true
  end

  def test_load
    alice = MiniTest::Mock.new
    bob = MiniTest::Mock.new
    alice.expect :hash, 1
    bob.expect :hash, 2

    board = Board.load(alice => {}, bob => {})
    board.tiles.length.must_equal 1
    board[0,0].empty_space?.must_equal true

    board = Board.load(alice => {Spider:[[0,0], [0,1]]},
                       bob => {Queen:[[1,0]]})
    [[[0,0], Insect::Spider, alice],
     [[0,1], Insect::Spider, alice],
     [[1,0], Insect::Spider, bob]].each do |location,klass,player|
       insect = board[*location]
       insect.class.must_equal klass
       insect.player.must_equal player
     end
  end

  def test_neighbors
    Board.neighbors(0,0).must_equal [[-1,0], [0,-1], [0,1], [1,-1], [1,0], [1,1]]
    Board.neighbors(0,1).must_equal [[-1,0], [-1,1], [-1,2], [0,0], [0,2], [1,1]]

    [[-1,0], [0,-1], [0,1], [1,-1], [1,0], [1,1]].each do |location|
      @board[*location] = EmptySpace.new(@board)
    end
    @board.neighbors(0,0)[:insects].must_equal []
    @board.neighbors(0,0)[:spaces].all?(&:empty_space?).must_equal true
    @board.neighbors(0,0)[:spaces].length.must_equal 6

    insect = MiniTest::Mock.new
    insect.expect :empty_space?, false
    @board[1,0] = insect
    @board.neighbors(0,0)[:spaces].length.must_equal 5
    @board.neighbors(0,0)[:insects].must_equal [insect]
  end

  def test_add_insect
    ant = MiniTest::Mock.new
    ant.expect :must_equal, true, [ant]
    @board[0,0] = ant
    @board[0,0].must_equal ant
  end

  def test_location_of
    insect = MiniTest::Mock.new
    @board[0,0] = insect
    @board.location_of(insect).must_equal [0,0]
  end

  def test_one_hive
  end
end
