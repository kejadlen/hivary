require 'test_helper'

class TestBoard < HiveTestCase
  def setup
    super

    @board = Board.new
  end

  def test_init
    assert_equal 1, @board.tiles.length
    assert_equal EmptySpace, @board[0,0].class
  end

  def test_load
    board = Board.load(@alice => {Spider:[[0,0]]},
                       @bob   => {Ant:[[0,1]]})

    assert_equal Insect::Spider, board[0,0].class
    assert_equal Insect::Ant, board[0,1].class
    assert_equal 10, board.tiles.length
    assert_equal [Insect::Spider], @alice.insects.map(&:class)
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

  def test_to_s
    alice = MiniTest::Mock.new
    alice.expect :current_player?, true
    alice.expect :insects, []
    bob = MiniTest::Mock.new
    bob.expect :current_player?, true
    bob.expect :insects, []
    board = Board.load(alice => {Spider:[[0,0]]},
                       bob   => {Ant:[[0,1]]})
    assert_equal " \e[37mE\e[0m \e[37mE\e[0m\n\e[37mE\e[0m \e[32mA\e[0m \e[37mE\e[0m\n \e[37mE\e[0m \e[32mS\e[0m \e[37mE\e[0m\n  \e[37mE\e[0m \e[37mE\e[0m",
                 board.to_s
  end
end
