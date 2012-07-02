require 'json'

require 'test_helper'

class TestBase < HiveTestCase
  def setup
    super

    @insect = Insect::Base.new(@alice)
  end

  def test_init
    assert_equal @alice, @insect.player
    assert_nil @insect.location
  end

  def test_can_play_next_to_opponent_on_second_turn
    @game.turn = 1

    refute_empty @insect.valid_placements

    @board[1,1] = Insect::Base.new(@alice)
    @game.turn = 3

    assert_equal [[0,2], [1,2], [2,1]], @insect.valid_placements
  end

  def test_can_play_into_surrounded_space
    @game.turn = 2

    assert_includes Insect::Spider.new(@alice).valid_placements, [0,0]
    refute_includes Insect::Spider.new(@bob).valid_placements, [0,0]
  end

  def test_valid_placements
    @game.turn = 2
    assert_equal [[-1,0], [0,-1], [0,1]], @insect.valid_placements
    assert @insect.can_play?
  end

  def test_invalid_placement
    @alice.insects << Insect::Queen.new(@alice)

    @game.turn = 6
    assert_raises(QueenNotPlayed) { @insect.play([0,1]) }
    refute @insect.can_play?

    @game.turn = 2
    assert_raises(InvalidLocation) { @insect.play([2,0]) }
    assert @insect.can_play? # this doesn't check for invalid locations
  end

  def test_valid_moves
    assert_equal [[1,-1], [1,1]], @board[0,0].valid_moves
    assert @board[0,0].can_move?
  end

  def test_invalid_moves
    @game.turn = 0
    @alice.insects << Insect::Queen.new(@alice)

    @game.expect :started?, true
    assert @board[0,0].played?
    e = assert_raises(QueenNotPlayed) { @board[0,0].move([1,1]) }
    refute @board[0,0].can_move?

    @game.expect :started?, true
    @board[2,0] = @alice.queen
    assert_raises(InvalidLocation) { @board[0,0].move([2,2]) }
    assert @board[0,0].can_move? # this doesn't check for invalid locations
  end

  def test_cant_move_even_if_hive_is_relinked
    assert_raises(OneHiveError) { @alice.queen.validate_move }
  end

  def test_freedom_to_move_in
    # TODO
  end

  def test_freedom_to_move_out
    @game.turn = 0

    ant = @board[1,0]
    assert_raises(InvalidLocation) { ant.move([2,-1]) }

    @board.source[[1,-1]] = Stack.new
    ant.move([2,-1])

    assert @board[1,0].nil?
    assert_equal ant, @board[2,-1]
  end

  def test_play
    @game.turn = 2
    @insect.play([0,-1])
    assert_equal @insect, @board[0,-1]
  end

  def test_to_json
    insect = JSON.load(@insect.to_json)
    assert_equal 'Base', insect['klass']
    assert_nil insect['location']

    ant = JSON.load(Insect::Ant.new(@bob).to_json)
    assert_equal 'Ant', ant['klass']
    assert_nil insect['location']
  end
end
