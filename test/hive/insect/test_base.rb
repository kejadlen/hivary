require 'test_helper'

require 'hive'
require 'hive/board'
require 'hive/insect/base'

class TestBase < HiveTestCase
  def setup
    @game = MiniTest::Mock.new
    @board = MiniTest::Mock.new
    @alice = MiniTest::Mock.new
    @insect = Insect::Base.new(@alice)
  end

  def test_init
    @alice.expect :==, true, [@alice]
    assert_equal @alice, @insect.player
    assert_nil @insect.location
  end

  def test_played
    refute @insect.played?

    @insect.location = [0,0]

    assert @insect.played?
  end

  def test_can_place_on_second_turn
    bob = MiniTest::Mock.new
    @alice.expect :current_player?, true
    @alice.expect :game, @game
    board = Board.load(@alice => {},
                       bob => {Base:[[0,0]]})
    @alice.expect :board, board
    @game.expect :turn, 1
    assert_equal Board.neighbors(0,0), @insect.valid_placements
  end

  def test_valid_placements
  end

  def test_place
  end
end
