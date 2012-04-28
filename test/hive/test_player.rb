require 'test_helper'

require 'hive/player'
require 'hive/insect/base'

class TestPlayer < HiveTestCase
  def setup
    @alice = Player.new('Alice')
    @game = MiniTest::Mock.new
  end

  def test_init
    assert_equal 'Alice', @alice.name
    assert_equal [], @alice.insects
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
  end
end
