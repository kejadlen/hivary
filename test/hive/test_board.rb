require 'json'
require 'test_helper'

class TestBoard < HiveTestCase
  def setup
    @board = Board.new

    super
  end

  def test_init
    assert_equal 1, @board.length
    assert_nil @board[0,0]
  end

  def test_load
    assert_equal Insect::Spider, @board[0,0].class
    assert_equal Insect::Ant, @board[0,1].class
    assert_equal 10, @board.length
    assert_equal [Insect::Spider], @alice.insects.map(&:class)
  end

  def test_neighbors
    assert_equal [[-1,0], [0,-1], [0,1], [1,-1], [1,0], [1,1]],
                 Board.neighbors(0,0)
    assert_equal [[-1,0], [-1,1], [-1,2], [0,0], [0,2], [1,1]],
                 Board.neighbors(0,1)
  end

  def test_one_hive
    assert Board.one_hive?(@board.insects.map(&:location))
    @board.delete(@board[1,0])
    refute Board.one_hive?(@board.insects.map(&:location))
  end

  def test_assignment
    stack = Stack.new([1,0])
    @board.source[[1,0]] = stack

    insect = MiniTest::Mock.new
    insect.expect :==, true, [insect]
    insect.expect :stack=, nil, [stack]
    @board[1,0] = insect

    assert_equal insect, @board[1,0]
    assert_equal 7, @board.length
    assert_equal 6, @board.select {|_,stack| stack.empty? }.length
  end

  def test_can_slide
    refute @board.can_slide?([1,1], [1,0])
    assert @board.can_slide?([1,1], [0,1])
  end

  def test_remove_empty_spaces
    @game.turn = 10

    @board[0,1].move([0,0])
    
    @game.players = [@bob, @alice]
    @board[0,-1].move([0,0])

    @game.players = [@alice, @bob]
    @board[1,1].move([0,0])

    @game.players = [@bob, @alice]
    @board[1,-1].move([0,0])

    assert_equal 8, @board.source.select {|_,v| v.empty? }.length
  end

  def test_neighbors
    neighbors = @board.neighbors(0,0)

    assert_equal 3, neighbors[:spaces].length
    assert_equal [[-1,0], [0,-1], [0,1]], neighbors[:spaces]
    assert_equal 3, neighbors[:insects].length
    assert_equal [[1,-1], [1,0], [1,1]], neighbors[:insects].map(&:location)
  end

  def test_to_s
    assert_equal " \e[37mE\e[0m \e[37mE\e[0m\n\e[37mE\e[0m \e[31mA\e[0m \e[37mE\e[0m\n \e[37mE\e[0m \e[32mS\e[0m \e[37mE\e[0m\n  \e[37mE\e[0m \e[37mE\e[0m", @board.to_s
  end

  def test_to_json
    board = Board.new
    [[1,0], [1,-1], [1,1]].each do |location|
      board[*location] = Insect::Base.new(@alice)
    end
    board[0,0] = Insect::Base.new(@bob)
    beetle = Insect::Beetle.new(@alice)
    board.source[[0,0]] << beetle
    beetle.stack = board.source[[0,0]]

    source = JSON.load(board.to_json)['source']
    assert_equal [[0,0], [1,-1], [1,0], [1,1]], source.map(&:first).sort
    stack = source.assoc([0,0])[1]
    assert_equal [['Base', 1], ['Beetle', 0]], stack
  end
end
