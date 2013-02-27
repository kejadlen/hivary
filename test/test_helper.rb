require 'set'

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'simplecov'; SimpleCov.start { command_name 'MiniTest' }

# require 'fivemat/minitest/autorun'
require 'minitest/autorun'
require 'minitest/emoji'
require 'minitest/pride'

require 'hive'

# So we don't need to do mock.expect :hash everywhere.
class MiniTest::Mock
  def hash; super; end
end

class GameMock < MiniTest::Mock
  attr_accessor :board, :players, :turn

  def current_player; self.players.first; end
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
    @game.players = @players
    @players.each {|player| player.game = @game }
  end

  def _board_path
    name ||= "#{self.class.name.split('::').last}##{self.__name__}.json"
    File.join(FIXTURE_PATH, name)
  end

  def save_board
    File.open(self._board_path, 'w') {|f| f << @board.to_json }
  end

  def load_board(name=nil)
    path = self._board_path

    @board = if File.exists?(path)
               Board.load(@players, JSON.load(File.read(path)))
             else
               Board.new
             end
    @game.board = @board
  end
end
