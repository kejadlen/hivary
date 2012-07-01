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
    name = "#{self.class.name.split('::').last}##{self.__name__}.json"
    path = File.join(FIXTURE_PATH, name)

    @board = (File.exists?(path)) ? Board.load(@players, File.read(path)) : Board.new
    @game.board = @board
  end
end
