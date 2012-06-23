require 'eventmachine'
require 'json'

require 'test_helper'

require 'hive/server'

class FakeSocketClient < EM::Connection
  include EM::P::ObjectProtocol
  def serializer; JSON; end

  attr_reader :data

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
    EM.run do
      @server = Server.new
      @server.start

      @socket = EM.connect('0.0.0.0', 3000, FakeSocketClient)
      @socket.send_object({method:'register', args:['alice']})
      @socket.onreceive {}

      yield

      EM.add_timer(timeout) { EM.stop }
    end
  end

  def test_json_parse_error
    em do
      @socket.send_data([1, '{'].pack('Na*'))
      # @socket.onmessage = lambda do |obj|
      @socket.onreceive do |obj|
        assert_equal 401, obj['status']
        EM.stop
      end
    end
  end

  def test_method_not_allowed
    em do
      @socket.send_object({method:'foo', args:['bob']})
      @socket.onreceive do |obj|
        assert_equal 405, obj['status']
        EM.stop
      end
    end
  end

  def test_register
    em do
      @socket.send_object({method:'register', args:['bob']})
      @socket.onreceive do |obj|
        assert_equal 200, obj['status']
        refute_nil obj['body']

        assert_equal ['bob'], @server.names

        EM.stop
      end
    end
  end

  def test_register_error
    em do
      socket = EM.connect('0.0.0.0', 3000, FakeSocketClient)
      socket.send_object({method:'register', args:['alice']})
      socket.onreceive do |obj|
        assert_equal 409, obj['status']
        assert_equal 'DuplicateNameError', obj['body']
        EM.stop
      end
    end
  end

  def test_games
    em do
      @socket.send_object({method:'games'})
      @socket.onreceive do |obj|
        assert_equal 200, obj['status']
        assert_equal [], obj['body']
        EM.stop
      end
    end
  end

  def test_create_game
    em do
      @socket.send_object({method:'create_game'})
      @socket.onreceive do |obj|
        assert_equal 200, obj['status']
        refute_nil obj['body']

        assert_equal 1, @server.games.length
        assert_equal 'alice', @server.games[0].players[0].name

        EM.stop
      end
    end
  end

  def test_create_game_error
    em do
      socket = EM.connect('0.0.0.0', 3000, FakeSocketClient)

      socket.send_object({method:'create_game'})
      socket.onreceive do |obj|
        assert_equal 409, obj['status']
        assert_equal 'NotRegisteredError', obj['body']
        EM.stop
      end
    end
  end

  def test_join_game
    em do
      socket = EM.connect('0.0.0.0', 3000, FakeSocketClient)
      socket.send_object({method:'register', args:['bob']})
      socket.onreceive {}

      game_id = nil
      @socket.send_object({method:'create_game'})
      @socket.onreceive do |obj|
        game_id = obj['body']

        socket.send_object({method:'join_game', args:[game_id]})
        socket.onreceive do |obj|
          assert_equal 200, obj['status']

          assert_equal 0, @server.games[0].turn
          EM.stop
        end
      end
    end
  end

  def test_join_game_error
    em do
      socket = EM.connect('0.0.0.0', 3000, FakeSocketClient)
      socket.send_object({method:'register', args:['bob']})
      socket.onreceive {}

      socket.send_object({method:'join_game', args:[123456789]})
      socket.onreceive do |obj|
        assert_equal 409, obj['status']
        EM.stop
      end
    end
  end

  def test_move
    em do
      socket = EM.connect('0.0.0.0', 3000, FakeSocketClient)
      socket.send_object({method:'register', args:['bob']})
      socket.onreceive {}

      game_id = nil
      @socket.send_object({method:'create_game'})
      @socket.onreceive do |obj|
        game_id = obj['body']

        socket.send_object({method:'join_game', args:[game_id]})
        socket.onreceive do |obj|
          players = @server.games[0].players
          sockets = [@socket, socket]
          sockets << sockets.shift if players[0].name != 'alice'

          insect = players[0].insects.reject {|insect| Insect::Queen === insect }.sample
          sockets[0].send_object({method:'move', args:[insect.object_id, [0,0]]})
          sockets[0].onreceive do |obj|
            assert_equal 200, obj['status']

            assert_equal 1, @server.games[0].turn

            sockets[1].onreceive do |obj|
              assert_equal ['game'], obj.keys

              EM.stop
            end
          end
        end
      end
    end
  end
end
