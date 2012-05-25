require 'test_helper'

class TestBeetle < HiveTestCase
  def setup
    super

    self.setup_game_mock
  end

  def test_normal_movement
    board = Board.load(@alice => {Beetle:[[0,0]], Queen:[[1,0]], Grasshopper:[[0,1]]},
                       @bob   => {})
    @game.board = board

    beetle = board[0,0]
    beetle.valid_moves.wont_include [1,1]
  end

  def test_can_climb_onto_hive
    board = Board.load(@alice => {Beetle:[[1,0]], Queen:[[1,-2]], Grasshopper:[[2,-2]]},
                       @bob   => {Spider:[[0,0]], Ant:[[1,-1]]})
    @game.board = board

    beetle = board[1,0]
    beetle.valid_moves.sort.must_equal [[0,0], [1,-1], [1,1], [2,-1]]
  end

  def test_covers_insects
    board = Board.load(@alice => { Beetle:[[1,0]], Queen:[[1,-2]], Grasshopper:[[2,-2]] },
                       @bob   => { Queen:[[-1,0]], Spider:[[0,0]], Ant:[[1,-1]] })
    @game.board = board
    @game.current_player = @alice
    @game.turn = 0

    beetle = board[1,0]
    ant = board[1,-1]

    beetle.move([1,-1])

    beetle.stack.must_equal ant

    @game.expect :turn, 3

    # The stack is the color of the beetle
    Insect::Spider.new(@alice).valid_placements.must_include [2,-1]

    # Moving the beetle should uncover the ant
    spider = board[0,0]
    beetle.move([0,0])
    beetle.stack.must_equal spider
    board[1,-1].must_equal ant
  end

  def test_covered_insect_cant_move
    board = Board.load(@alice => { Beetle:[[1,0]], Queen:[[0,1]], Base:[[1,1], [-1,0], [0,0], [0,-1]] },
                       @bob => {})
    @game.board = board
    @game.current_player = @alice
    @game.turn = 0

    insect = board[0,0]
    beetle = board[1,0]

    beetle.move([0,0])

    assert_raises(IllegalOperation) { insect.move([1,0]) }
  end

  def test_stack_multiple_beetles
  end
end
