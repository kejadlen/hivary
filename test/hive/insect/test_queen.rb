require 'test_helper'

class TestQueen < HiveTestCase
  def setup
    super

    @queen = Insect::Queen.new(@alice)
    @alice.insects << @queen
  end

  def test_cant_place_first
    (0..1).each do |turn|
      @game.turn = turn
      assert_empty @queen.valid_placements
      assert_raises(IllegalOperation) { @queen.play([0,0]) }
    end
  end

  def test_can_play_on_turns_2_and_3
    (2..5).each do |turn|
      @game.turn = turn

      insect = Insect::Base.new(@alice)
      insect.play(insect.valid_placements.sample)

      refute_empty @queen.valid_placements
    end
  end

  def test_must_be_played_by_turn_4
    insect = Insect::Base.new(@alice)

    (6..7).each do |turn|
      @game.turn = turn

      assert_raises(QueenNotPlayed) { insect.play(insect.valid_placements.sample) }

      refute_empty @queen.valid_placements
    end
  end

  def test_must_be_played_for_other_insects_to_move
    @game.turn = 2

    base = @board[0,0]

    assert_raises(QueenNotPlayed) { base.move([1,0]) }

    @queen.play([1,0])

    base.move([1,1])
  end

  def test_moves_one_tile
    @alice.insects.delete(@queen)

    queen = @board[0,0]
    assert_equal [[-1,0], [0,1], [1,-1], [1,0]], queen.valid_moves
  end

  def test_cant_move_off_the_hive
    @alice.insects.delete(@queen)
    @game.board = @board
    @game.turn = 2

    queen = @board[1,0]
    assert_equal [[1,1], [2,-1]], queen.valid_moves
  end
end
