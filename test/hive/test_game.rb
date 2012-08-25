require 'json'

require 'test_helper'

class TestGame < HiveTestCase
  def setup
    super

    @game = Game.new
  end

  def test_init
    assert_equal [], @game.players
    refute_nil @game.board
    assert_nil @game.turn
  end

  def test_start
    2.times { @game.players << MiniTest::Mock.new }
    @game.players.each do |player|
      player.expect :prepare_insects, nil
    end

    assert_nil @game.turn

    @game.start

    @game.players.each {|player| player.verify }

    # TODO: test player randomization?

    assert_equal 0, @game.turn
  end

  def test_current_player
    @game.players << @alice << @bob
    assert_equal @game.current_player, @alice

    @game.players.clear
    @game.players << @bob << @alice
    assert_equal @game.current_player, @bob
  end

  def test_load
    game = Game.load({'players' => %w[ Alice Bob ],
                      'board' => JSON.load(@board.to_json),
                      'turn' => 5})
    assert_equal %w[ Alice Bob ], game.players.map(&:name)
    assert_equal 5, game.turn
    game.players.each do |player|
      assert_equal 11, player.insects.length
    end
  end

  def test_over
    refute @game.over?

    @game.turn = 0

    player = MiniTest::Mock.new
    queen = MiniTest::Mock.new
    queen.expect :surrounded?, true
    player.expect :queen, queen
    @game.players << player

    assert @game.over?
  end

  def test_play_ALL_the_insects
    [@alice, @bob].each {|player| player.join_game(@game) }
    @game.start

    insects = @game.current_player.insects - [@game.current_player.queen]
    until insects.empty?
      insect = (not @game.current_player.queen.played? and (1..3).include?(@game.turn / 2)) ? @game.current_player.queen : insects.sample
      insect.play(insect.valid_placements.sample)
      insects = @game.current_player.insects.reject {|insect| insect.played? } - [@game.current_player.queen]
    end
  end

  def test_to_json
    self.test_play_ALL_the_insects

    json = JSON.load(@game.to_json)

    assert_equal @game.players.map(&:name), json['players']
    assert_equal JSON.load(@game.board.to_json), json['board']
    assert_equal @game.turn, json['turn']
  end

  def test_expansions
    @game.expansions << :ladybug
    
    [@alice, @bob].each {|player| player.join_game(@game) }
    @game.start

    assert_includes @game.insects, Insect::Ladybug
    assert_equal @game.insects[Insect::Ladybug], 1

    @game.expansions << :mosquito

    assert_includes @game.insects, Insect::Mosquito
    assert_equal @game.insects[Insect::Mosquito], 1
  end
end
