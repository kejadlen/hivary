require 'test_helper'

require 'hive/player'
require 'hive/insect/base'

class TestPlayer < HiveTestCase
  def setup
    @alice = Player.new('Alice')

    @game = MiniTest::Mock.new
    @alice.game = @game
  end

  def test_init
    assert_equal 'Alice', @alice.name
    assert_equal [], @alice.insects
  end

  def test_current_player
    @game.expect :current_player, 0
    refute @alice.current_player?

    @game.expect :current_player, @alice
    assert @alice.current_player?
  end

  def test_join_game
    @game.expect :players, []

    @alice.join_game(@game)

    @game.verify

    @game.expect :==, true, [@game]
    assert_equal @game, @alice.game
    assert_equal @game.players, [@alice]
  end

  def test_prepare_insects
    @game.expect :insects, {Insect::Base => 2}
    @alice.game = @game

    @alice.prepare_insects

    assert_equal 2, @alice.insects.length
    assert_equal [Insect::Base, Insect::Base],
                 @alice.insects.map(&:class)
  end

  def test_move
    board = MiniTest::Mock.new
    insect = Insect::Base.new(@alice)
    @alice.insects << insect
    @alice.game = @game
    @game.expect :board, board
    @game.expect :turn, 0
    @game.expect :turn=, 1, [1]
    @game.expect :current_player, @alice

    # @alice.move(insect, [0,0])

    # @game.verify
  end
end
