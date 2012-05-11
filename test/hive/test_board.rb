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

  def test_one_hive
    board = Board.load(@alice => {Queen:[[0,0]], Ant:[[1,0]], Beetle:[[2,0]]},
                       @bob   => {Ant:[[1,-1]], Queen:[[3,0]]})

    assert Board.one_hive?(board.insects.map(&:location))
    board.tiles.delete([1,0])
    refute Board.one_hive?(board.insects.map(&:location))
  end

  def test_assignment
    insect = MiniTest::Mock.new
    insect.expect :==, true, [insect]
    insect.expect :empty_space?, false
    insect.expect :location=, [1,0], [[1,0]]
    @board[1,0] = insect

    assert_equal insect, @board.tiles[[1,0]]
    assert_equal 7, @board.tiles.length

    insect.expect :empty_space?, false
    assert_equal 6, @board.tiles.select {|_,tile| tile.empty_space? }.length
  end

  def test_can_slide
    self.setup_game_mock
    @game.expect :current_player, @alice
    board = Board.load(@alice => { Spider:[[0,0]], Queen:[[2,1]] },
                       @bob   => { Spider:[[1,2]] })

    refute board.can_slide?([1,1], [1,0])
    assert board.can_slide?([1,1], [0,1])
  end

  # def test_remove_empty_spaces
    # game = MiniTest::Mock.new
    # game.expect :current_player, @alice
    # [@alice, @bob].each {|player| player.game = game }
    # board = Board.load(@alice => {Spider:[[0,0]]},
                       # @bob   => {})
    # board[-2,0] = EmptySpace.new(board, nil)
    # board.remove_empty_spaces!

    # refute_nil board[-1,0]
    # refute_nil board[1,0]
    # assert_nil board[-2,0]
  # end

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
