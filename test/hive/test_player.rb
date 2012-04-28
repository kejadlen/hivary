require 'test_helper'

require 'hive/game'
require 'hive/hive'
require 'hive/player'

class TestPlayer < HiveTestCase
  def setup
    @alice = Player.new('Alice')
    @bob = Player.new('Bob')
    @game = Game.new

    @alice.join(@game)
    @bob.join(@game)
    @game.start!
  end

  def test_initialize
    player = Player.new('Player')
    player.insects.must_equal []
  end

  def test_join_errors
    game = Game.new
    proc { @alice.join(game) }.must_raise IllegalMove
  end

  def test_join
    alice = Player.new('Alice')
    bob = Player.new('Bob')
    game = Game.new

    alice.join(game)
    game.players.must_equal [alice]

    bob.join(game)
    game.players.must_equal [alice, bob]
  end

  def test_move_errors
    @game.turn = nil
    proc { @game.current_player.move(nil, nil) }.must_raise IllegalMove

    player = @game.players.last

    @game.turn = 0
    proc { @game.current_player.move(player.insects.sample, nil) }.must_raise IllegalMove
    @game.turn.must_equal 0

    proc { player.move(player.insects.sample, nil) }.must_raise IllegalMove
    @game.turn.must_equal 0
  end

  def test_move_unplayed_insect
    current_player = @game.current_player
    insect = MiniTest::Mock.new
    insect.expect :player, current_player
    insect.expect :played?, false
    insect.expect :place, nil, [[0,0]]

    current_player.move(insect, [0,0])
    insect.verify
    
    @game.current_player.wont_equal current_player
    @game.turn.must_equal 1
  end

  def test_move_played_insect
    current_player = @game.current_player

    @game.board[0,0] = current_player.queen

    insect = MiniTest::Mock.new
    insect.expect :player, current_player
    insect.expect :played?, true
    insect.expect :move, nil, [[0,0]]

    current_player.move(insect, [0,0])
    insect.verify

    @game.current_player.wont_equal current_player
    @game.turn.must_equal 1
  end

  def test_move_nonqueen_before_fourth_turn
    current_player = @game.current_player
    insect = MiniTest::Mock.new
    insect.expect :player, current_player
    insect.expect :played?, false

    [6, 7].each do |turn|
      @game.turn = turn

      proc { current_player.move(insect, [0,0]) }.must_raise IllegalMove
      @game.turn.must_equal turn
    end
  end
end
