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

  def test_played
    refute @insect.played?

    @insect.location = [0,0]

    assert @insect.played?
  end

  def test_can_place_on_second_turn
    game = Game.load({@alice => {},
                      @bob => {Base:[[0,0]]}},
                      turn:1)
    assert_equal Board.neighbors(0,0), @insect.valid_placements
  end

  def test_valid_placements
  end

  def test_place
  end
end
