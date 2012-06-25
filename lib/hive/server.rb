require 'eventmachine'
require 'json'

require 'hive'

module Hive
  class ServerError < HiveError; end
  class DuplicateNameError < ServerError; end
  class NotRegisteredError < ServerError; end

  class ConnPlayer < Player
    attr_reader :connection

    def initialize(name, connection)
      @connection = connection
      super(name)
    end
  end

  class Server
    attr_reader :games, :names

    def initialize
      @games = []
      @names = []
    end

    def start
      @instance = EM.start_server('0.0.0.0', 3000, Connection) do |con|
        con.server = self
      end
    end

    def stop
      EM.stop_server(@instance)
    end
  end

  class Connection < EM::Connection
    attr_accessor :server

    attr_accessor :player, :opponent

    AllowedMethods = %w[ create_game games join_game move register ]

    def create_game
      raise NotRegisteredError if self.player.nil?

      game = Game.new
      self.server.games << game

      self.player.join_game(game)

      game
    end

    def games; self.server.games; end

    def join_game(game_id)
      game = self.server.games.find {|game| game.object_id == game_id }
      self.player.join_game(game)
      game.start
      game
    end

    def move(insect_id, location)
      insect = self.player.insects.find {|insect| insect.object_id == insect_id }
      self.player.move(insect, location)

      game = self.player.game
      game.current_player.connection.send_object({game:game})

      if game.over?
        game.players.last.connection.send_object({game:game})
      end

      game
    end

    def register(name)
      raise DuplicateNameError if self.server.names.include?(name)

      self.server.names.delete(self.player.name) unless self.player.nil?

      self.server.names << name
      self.player = ConnPlayer.new(name, self)
      self.player
    end
    
    def receive_data(data)
      (@buf ||= '') << data

      while @buf.size >= 4
        if @buf.size >= 4+(size=@buf.unpack('N').first)
          @buf.slice!(0,4)
          self.receive_object(JSON.load(@buf.slice!(0,size)))
        else
          break
        end
      end
    rescue JSON::ParserError
      self.send_object({status:401})
    end

    def receive_object(obj)
      method = obj['method']
      args = obj['args'] || []
      if AllowedMethods.include?(method)
        result = self.send(method, *args)
        self.send_object({status:200, body:result})
      else
        self.send_object({status:405})
      end
    rescue ServerError => e
      self.send_object({status:409, body:e.class.to_s.split('::').last})
    rescue HiveError => e
      self.send_object({status:409, body:e.class.to_s.split('::').last})
    end
    
    def send_object(obj)
      data = JSON.dump(obj)
      self.send_data([data.bytesize, data].pack('Na*'))
    end
  end
end

if __FILE__ == $0
  EM::run {
    s = Hive::Server.new
    s.start
  }
end
