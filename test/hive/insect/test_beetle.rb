require 'test_helper'

class TestBeetle < HiveTestCase
  def test_normal_movement
    beetle = @board[0,0]
    refute_includes beetle.valid_moves, [1,1]
  end

  def test_one_hive
    # TODO
  end

  def test_can_climb_onto_hive
    beetle = @board[1,0]
    assert_equal [[0,0], [1,-1], [1,1], [2,-1]], beetle.valid_moves.sort
  end

  def test_covers_insects
    @game.turn = 0

    beetle = @board[1,0]
    ant = @board[1,-1]

    beetle.move([1,-1])
    
    assert_equal [ant, beetle].map(&:object_id), @board.source[[1,-1]].map(&:object_id)

    @game.expect :turn, 3

    # The stack is the color of the beetle
    assert_includes Insect::Spider.new(@alice).valid_placements, [2,-1]

    # Moving the beetle should uncover the ant
    spider = @board[0,0]
    beetle.move([0,0])
    assert_equal [spider, beetle].map(&:object_id), @board.source[[0,0]].map(&:object_id)
    assert_equal ant, @board[1,-1]
  end

  def test_covered_insect_cant_move
    @game.turn = 0

    insect = @board[0,0]
    beetle = @board[1,0]

    beetle.move([0,0])

    assert_raises(UnderAnotherInsect) { insect.move([1,0]) }
  end

  def test_stack_multiple_beetles
    @game.turn = 11

    @board[0,1].move([0,0])
    assert_equal @alice, @board[0,0].player
    
    @game.players = [@bob, @alice]
    @board[0,-1].move([0,0])
    assert_equal @bob, @board[0,0].player

    @game.players = [@alice, @bob]
    @board[1,1].move([0,0])
    assert_equal @alice, @board[0,0].player

    @game.players = [@bob, @alice]
    @board[1,-1].move([0,0])
    assert_equal @bob, @board[0,0].player

    assert_equal 5, @board.source[[0,0]].size
  end
end
