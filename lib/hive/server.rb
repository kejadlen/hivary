require 'eventmachine'
require 'logger'
require 'json'

require 'hive'

module Hive
  class ServerError < HiveError; end
  class DuplicateNameError < ServerError; end
  class NotRegisteredError < ServerError; end
  class NoGameError < ServerError; end

  class ConnPlayer < Player
    attr_reader :connection

    def initialize(name, connection)
      @connection = connection
      super(name)
    end
  end

  class Server
    attr_accessor :logger
    attr_reader :games, :users

    class << self
      def insect_from_move(game, insect)
        if insect['location'].nil?
          game.current_player.insects.find do |i|
            not i.played? and i.class.name.split('::').last == insect['klass']
          end
        else
          game.board[*insect['location']]
        end
      end
    end

    def initialize(opts={})
      @ip = opts.fetch(:ip, '0.0.0.0')
      @port = opts.fetch(:port, 3000)
      
      @logger = Logger.new('/dev/null')
      @games = []
      @users = {}
    end

    def start
      @instance = EM.start_server(@ip, @port, Connection) do |con|
        con.server = self
      end
    end

    def stop
      EM.stop_server(@instance)
    end
  end

  class Connection < EM::Connection
    attr_accessor :server
    attr_accessor :name, :opponent

    ALLOWED_METHODS = %w[ create_game game games join_game move register unregister ]

    def logger; self.server.logger; end
    def player; Maybe(self.server.users[self.name]); end

    def create_game
      game = Game.new
      self.server.games << game

      { id:game.object_id }
    end

    def game(game_id)
      game = self.server.games.find {|game| game.object_id == game_id }
      raise NoGameError if game.nil?

      {game:game.to_json}
    end

    def games
      self.server.games.map do |game|
        name = game.players[0].name rescue ''
        [game.object_id, name]
      end
    end

    def join_game(game_id)
      game = self.server.games.find {|game| game.object_id == game_id }
      raise NoGameError if game.nil?

      self.player.join_game(game)

      if game.players.length == 2
        self.opponent = game.players[0]
        self.opponent.connection.opponent = self.player

        game.start

        self.opponent.connection.send_object({ status:200,
                                               method:'join_game',
                                               body:{ id:game.current_player.object_id,
                                                      opp_id:self.player.object_id }})
      end

      hash = { id:game.current_player.object_id }
      hash[:opp_id] = self.opponent.object_id if self.opponent
      hash
    end

    def move(*last_move)
      insect,location = last_move

      game = self.player.game

      insect = Server.insect_from_move(game, insect)

      self.player.move(insect, location)

      self.opponent.connection.send_object({status:200,
                                            method:'move',
                                            body:{id:self.player.object_id,
                                                  last_move:last_move}})

      {id:self.player.object_id, last_move:last_move}
    end

    def register(name)
      raise DuplicateNameError if self.server.users.include?(name)

      # Unregister previously registered player
      self.server.users.delete(self.name)

      self.name = name

      player = ConnPlayer.new(self.name, self)
      self.server.users[self.name] = player
      player
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
      self.logger.info("received object #{obj}")

      method = obj['method']
      args = obj['args'] || []
      if ALLOWED_METHODS.include?(method)
        result = self.send(method, *args)
        self.send_object({status:200, method:method, body:result})
      else
        self.send_object({status:405})
      end
    rescue ServerError => e
      self.send_object({status:409, method:method, body:e.class.to_s.split('::').last})
    rescue HiveError => e
      self.send_object({status:409, method:method, body:e.class.to_s.split('::').last})
    end
    
    def send_object(obj)
      data = JSON.dump(obj)

      self.logger.debug(caller)
      self.logger.info("sending object #{data}")

      self.send_data([data.bytesize, data].pack('Na*'))
    end

    def unbind
      return unless self.player

      self.logger.info("unbinding #{self.name}")

      # TODO: Allow users to rejoin games
      self.server.games.delete_if {|game| game.players.include?(self.player) }
      self.server.users.delete(self.name)
    end
  end
end
