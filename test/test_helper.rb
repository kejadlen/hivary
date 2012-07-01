require 'set'

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'simplecov'; SimpleCov.start { command_name 'MiniTest' }

# require 'fivemat/minitest/autorun'
require 'minitest/autorun'

require 'hive'

# So we don't need to do mock.expect :hash everywhere.
class MiniTest::Mock
  def hash; super; end
end

class GameMock < MiniTest::Mock
  attr_accessor :board, :current_player, :players, :turn

  def over?; false; end
end

class HiveTestCase < MiniTest::Unit::TestCase
  include Hive

  FIXTURE_PATH = File.expand_path('../fixtures', __FILE__)

  def setup
    @alice = Player.new('Alice')
    @bob = Player.new('Bob')
    @players = [@alice, @bob]

    self.setup_game_mock
    self.load_board
  end

  def setup_game_mock
    @game = GameMock.new
    @players.each {|player| player.game = @game }
  end

  def load_board
    @board = Board.new
    @game.board = @board

    name = "#{self.class.name.split('::').last}##{self.__name__}.json"
    path = File.join(FIXTURE_PATH, name)
    return unless File.exists?(path)

    json = JSON.load(File.read(path))
    json['source'].each do |location, stack|
      stack.each do |insect,player|
        player = @players[player]
        insect = Insect.const_get(insect).new(player)
        player.insects << insect

        @board.source[location] ||= Stack.new(*location)
        @board.source[location] << insect
        insect.stack = @board.source[location]
      end
    end

    @board.map {|k,_| k }.each do |location|
      Board.neighbors(*location).each do |neighbor|
        @board.source[neighbor] ||= Stack.new(*neighbor)
      end
    end
  end
end
