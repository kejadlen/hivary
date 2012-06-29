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
    attr_reader :games, :players

    def initialize
      @logger = Logger.new('/dev/null')
      @games = []
      @players = []
    end

    def start(ip='0.0.0.0', port=3000)
      @instance = EM.start_server(ip, port, Connection) do |con|
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

    AllowedMethods = %w[ create_game games join_game move register unregister ]

    def logger; self.server.logger; end

    def create_game
      raise NotRegisteredError if self.player.nil?

      game = Game.new
      self.server.games << game

      self.player.join_game(game)

      timer = EM.add_periodic_timer(1) do
        if game.turn
          self.send_object({status:200, body:{id:game.current_player.object_id,
                                              opp_id:self.opponent.object_id,
                                              last_move:nil}})
          timer.cancel
        end
        # TODO: should probably add timeout logic at some point here
      end

      {id:game.object_id}
    end

    def games; self.server.games.map(&:object_id); end

    def join_game(game_id)
      game = self.server.games.find {|game| game.object_id == game_id }
      raise NoGameError if game.nil?

      self.opponent = game.players[0]
      self.opponent.connection.opponent = self.player

      self.player.join_game(game)
      game.start

      {id:game.current_player.object_id, opp_id:self.opponent.object_id}
    end

    def move(*last_move)
      insect,location = last_move

      game = self.player.game

      # insect = self.player.insects.find {|insect| insect.object_id == insect_id }
      insect = if insect['location'].nil?
                 self.player.insects.find {|i| not i.played? and
                                           i.class.to_s == insect['klass'] }
               else
                 game.board[*insect['location']]
               end

      self.player.move(insect, location)

      self.opponent.connection.send_object({status:200,
                                            body:{id:self.player.object_id,
                                                  last_move:last_move}})
                                            # body:{last_move:{id:self.player.object_id,
                                                             # insect:insect}}})#,
                                                             # location:location}}})

      # {last_move:{id:self.player.object_id, insect:insect}} #, location:location}}
      {id:self.player.object_id, last_move:last_move}
    end

    def register(name)
      raise DuplicateNameError if self.server.players.map(&:name).include?(name)

      # Unregister previously registered player
      self.server.players.delete(self.player) unless self.player.nil?

      self.player = ConnPlayer.new(name, self)
      self.server.players << self.player
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
      self.logger.info("received object #{obj}")

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

      self.logger.debug(caller)
      self.logger.info("sending object #{data}")

      self.send_data([data.bytesize, data].pack('Na*'))
    end

    def unbind
      self.server.players.delete(self.player)
      self.server.games.delete_if {|game| game.players.include?(self.player) }
    end
  end
end
