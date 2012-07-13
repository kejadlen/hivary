require 'eventmachine'
require 'json'

require 'test_helper'

require 'hive/server'

class FakeSocketClient < EM::Connection
  include EM::P::ObjectProtocol
  def serializer; JSON; end

  attr_reader :blocks, :data, :sent

  def initialize
    @blocks = []
    @data = []
    @sent = []
  end

  def onreceive(&blk)
    @blocks << blk
  end

  def receive_object(obj)
    @data << obj
    block = @blocks.shift
    block.call(obj) if block
  end

  def send_object(obj)
    @sent << obj
    super
  end
end

class TestServer < HiveTestCase
  def em(timeout=0.1)
    @stopped = false

    EM.run do
      @server = Server.new
      @server.start

      @alice = EM.connect('0.0.0.0', 3000, FakeSocketClient)
      @alice.send_object({:method => 'register', :args => ['alice']})
      @alice.onreceive {}

      @bob = EM.connect('0.0.0.0', 3000, FakeSocketClient)

      yield

      EM.add_timer(timeout) { EM.stop }
    end

    assert_empty @alice.blocks
    assert_empty @bob.blocks

    assert @stopped, 'EM test ended early!'
  end

  def stop
    @stopped = true
    EM.stop
  end

  def test_json_parse_error
    em do
      @alice.send_data([1, '{'].pack('Na*'))
      # @alice.onmessage = lambda do |obj|
      @alice.onreceive do |obj|
        assert_equal 401, obj['status']
        stop
      end
    end
  end

  def test_method_not_allowed
    em do
      @alice.send_object({:method => 'foo', :args => ['bob']})
      @alice.onreceive do |obj|
        assert_equal 405, obj['status']
        stop
      end
    end
  end

  def test_register
    em do
      @alice.send_object({:method => 'register', :args => ['bob']})
      @alice.onreceive do |obj|
        assert_equal 200, obj['status']
        refute_nil obj['body']

        assert_includes @server.users, 'bob'

        stop
      end
    end
  end

  def test_register_error
    em do
      @bob.send_object({:method => 'register', :args => ['alice']})
      @bob.onreceive do |obj|
        assert_equal 409, obj['status']
        assert_equal 'DuplicateNameError', obj['body']
        stop
      end
    end
  end

  def test_games
    em do
      @alice.send_object({:method => 'games'})
      @alice.onreceive do |obj|
        assert_equal 200, obj['status']
        assert_equal [], obj['body']
      end

      @alice.send_object({:method => 'create_game'})
      @alice.onreceive {}

      @alice.send_object({:method => 'games'})
      @alice.onreceive do |obj|
        game = @server.games[0]

        assert_equal 200, obj['status']
        assert_equal [[game.object_id, '']], obj['body']

        stop
      end
    end
  end

  def test_create_game
    em do
      @alice.send_object({:method => 'create_game'})
      @alice.onreceive do |obj|
        assert_equal 200, obj['status']

        assert_equal 1, @server.games.length

        game = @server.games[0]
        assert_equal obj['body']['id'], game.object_id
        assert_empty game.players

        stop
      end
    end
  end

  def test_join_game
    em(2) do
      bob = EM.connect('0.0.0.0', 3000, FakeSocketClient)
      bob.send_object({:method => 'register', :args => ['bob']})
      bob.onreceive {}

      game_id = nil

      @alice.send_object({:method => 'create_game'})

      @alice.onreceive do |obj|
        game_id = obj['body']['id']

        @alice.send_object({:method => 'join_game', :args => [game_id]})
      end

      @alice.onreceive do |obj|
        assert_equal 200, obj['status']
        refute_empty @server.games[0].players

        bob.send_object({:method => 'join_game', :args => [game_id]})
      end

      bob.onreceive do |obj|
        assert_equal 200, obj['status']
        assert_equal 0, @server.games[0].turn
      end

      @alice.onreceive do |obj|
        assert_equal 200, obj['status']
        assert_nil obj['body']['last_move']

        stop
      end
    end
  end

  def test_join_game_error
    em do
      socket = EM.connect('0.0.0.0', 3000, FakeSocketClient)
      socket.send_object({:method => 'register', :args => ['bob']})
      socket.onreceive {}

      socket.send_object({:method => 'join_game', :args => [123456789]})
      socket.onreceive do |obj|
        assert_equal 409, obj['status']
        stop
      end
    end
  end

  def test_move
    em(2) do
      socket = EM.connect('0.0.0.0', 3000, FakeSocketClient)
      socket.send_object({:method => 'register', :args => ['bob']})
      socket.onreceive {}

      game_id = nil
      sockets = [@alice, socket]
      insect = nil

      @alice.send_object({:method => 'create_game'})

      @alice.onreceive do |obj|
        game_id = obj['body']['id']

        @alice.send_object({:method => 'join_game', :args => [game_id]})
      end

      @alice.onreceive do |obj|
        socket.send_object({:method => 'join_game', :args => [game_id]})
      end

      @alice.onreceive {}

      socket.onreceive do |obj|
        players = @server.games[0].players
        sockets << sockets.shift if players[0].name != 'alice'

        insects = players[0].insects.reject {|insect| Insect::Queen === insect }.sample
        sockets[0].send_object({:method => 'move', :args => [insect, [0,0]]})
      end

      sockets[0].onreceive do |obj|
        assert_equal 200, obj['status']
        assert_equal @server.games[0].players[1].object_id, obj['body']['id']
        assert_equal insect.class.name.split('::').last, obj['body']['last_move'][0]['klass']
        assert_equal nil, obj['body']['last_move'][0]['location']
        assert_equal [0,0], obj['body']['last_move'][1]

        assert_equal 1, @server.games[0].turn

        stop
      end
    end
  end

  def test_unregister
    em do
      @alice.send_object({:method => 'register', :args => ['bob']})
      @alice.onreceive do
        @alice.close_connection
        stop
      end
    end

    assert_empty @server.users
  end

  def test_game
    em do
      self.load_board('TestGrasshopper#test_jumps_in_straight_lines.json')
      game = Game.new(@players, @board)
      @server.games << game

      @alice.send_object({:method => 'game', :args => [game.object_id]})
      @alice.onreceive do |obj|
        assert_equal 200, obj['status']
        assert_equal game.to_json, obj['body']['game']
        stop
      end
    end
  end

  # TODO
  def test_game_over
  end
end
