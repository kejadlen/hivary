require 'test_helper'

require 'hive/board'
require 'hive/tile'
require 'hive/insect/insect'

class TestInsect < HiveTestCase
  def setup
    @player = MiniTest::Mock.new
    @game = MiniTest::Mock.new
    @board = Board.new
    @player.expect :name, 'Alice'
    @player.expect :current_player?, true
    @player.expect :game, @game
    @game.expect :board, @board

    @insect = Insect::Insect.new(@player)
  end

  def test_played
    board = MiniTest::Mock.new
    @game.expect :board, board

    board.expect :tiles, {}
    @insect.played?.must_equal false

    board.expect :tiles, { [0,0] => @insect }
    @insect.played?.must_equal true
  end

  def test_place_error
    @board[0,0] = @insect
    proc { @insect.place([0,0]) }.must_raise IllegalMove

    @board[0,0] = EmptySpace.new(@board)
    proc { @insect.place([0,1]) }.must_raise IllegalMove

    @board[0,0] = Insect::Insect.new(@player)
    proc { @insect.place([0,0]) }.must_raise IllegalMove

    player = MiniTest::Mock.new
    player.expect :!=, true, [@player]
    @game.expect :turn, 2
    @board[0,0] = Insect::Insect.new(player)
    @board[0,1] = EmptySpace.new(@board)
    proc { @insect.place([0,1]) }.must_raise IllegalMove
  end

  def test_place
    player = MiniTest::Mock.new
    player.expect :name, 'Bob'
    player.expect :current_player?, false
    player.expect :!=, true, [@player]
    @game.expect :turn, 1
    @board[0,0] = Insect::Insect.new(player)
    @board[0,1] = EmptySpace.new(@board)

    @insect.place([0,1])
    @board[0,1].must_equal @insect
    (Board.neighbors(0,1) - [[0,0]]).each do |location|
      @board[*location].empty_space?.must_equal true
    end
  end

  def test_move_error
    proc { @insect.move([0,0]) }.must_raise IllegalMove

    queen = MiniTest::Mock.new
    queen.expect :played?, false
    @player.expect :queen, queen
    @board[0,0] = @insect
    proc { @insect.move([0,0]) }.must_raise IllegalMove

    board = MiniTest::Mock.new
    board.expect :tiles, @board.tiles
    board.expect :one_hive?, true, [@insect]
    queen.expect :played?, true
    @game.expect :board, board
    proc { @insect.move([0,0]) }.must_raise IllegalMove
  end

  def test_move
  end
end
