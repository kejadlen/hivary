#!/usr/bin/env ruby

require 'logger'

require 'eventmachine'
require 'highline'
require 'json'

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'hive'
require 'hive/server'

module Hive
  class Client < EM::Connection
    attr_accessor :logger

    def game_over
      exit
    end

    def make_move
      raise NotImplementedError
    end

    def start_game
      game = Game.new
      opponent = Player.new(@body['opp_id'])
      [@player, opponent].each {|player| player.join_game(game) }
      game.start

      game.players << game.players.shift if game.current_player.name != @body['id']

      self.make_move if @player.current_player?
    end

    ### 

    def _create_game
    end

    def _games
    end

    def _join_game
      self.start_game if @body.include?('opp_id')
    end

    def _move
      last_move = @body['last_move']
      return unless last_move

      game = @player.game
      insect = Server.insect_from_move(game, last_move[0])
      game.current_player.move(insect, last_move[1])

      self.game_over if game.over?
      self.make_move
    end

    def _register
      @player = Player.new(@body['id'])
    end

    def method_missing(method, *args)
      if Connection::ALLOWED_METHODS.include?(method.to_s)
        self.send_object({method:method, args:args})
      else
        super
      end
    end

    ### EventMachine

    include EM::P::ObjectProtocol
    def serializer; JSON; end

    def post_init
      @logger = Logger.new(STDOUT)

      @game = nil
      @player_id = nil
    end

    def receive_object(obj)
      @logger.debug("received object #{obj}")

      method = "_#{obj['method']}"
      method << '_error' if obj['status'] != 200
      @body = obj['body']

      self.send(method.to_sym)
    end

    def send_object(obj)
      @logger.debug("sending object #{obj}")

      super(obj)
    end
  end

  class RandomBot < Client
    def game_over
      say('Game over!')

      winner = game.players.delete_if {|player| player.queen.surrounded? }
      if winner.empty?
        say("Tie - both queens are surrounded!")
      elsif winner[0] == @player
        say("You win!")
      else
        say("You lose!")
      end

      exit
    end

    def make_move
      return unless @player.current_player?

      say(@player.board.to_s)

      insect,locations = @player.legal_insects.sample
      location = locations.sample
      self.move(insect, location)
    end
  end

  class CLIClient < Client
    def _create_game
      super

      self.join_game(@body['id'])
    end

    def _games
      choose do |menu|
        menu.choice('Refresh list of games') do
          self.games
        end
        @body.each do |game_id,name|
          menu.choice("#{game_id} (#{name})") do
            self.join_game(game_id)
          end
        end
        menu.choice('Create new game') do
          self.create_game
        end
      end
    end

    def make_move
      unless @player.current_player?
        say('Waiting for opponent to move...')
        return
      end

      insects = @player.legal_insects

      say(@player.game.board.to_s)

      choose do |menu|
        insects.each do |insect,locations|
          locations.sort!
          menu.choice(insect) do
            choose do |submenu|
              submenu.index = :letter

              self.print_board(insect, locations)

              locations.each do |location|
                submenu.choice(location) do
                  self.move(insect, location)
                end
              end
            end
          end
        end
      end
    end

    def print_board(insect, locations)
      min_x = @player.game.board.min_x
      rows = @player.game.board.to_a do |insect|
        color = (insect.nil?) ? 37 : (insect.player.current_player?) ? 32 : 31
        letter = (insect.nil?) ? 'E' : insect.class.to_s.split('::').last[0]
        "\e[#{color}m#{letter}\e[0m"
      end

      index = 'a'
      locations.each do |x,y|
        rows.assoc(y).last[x] = "\e[1;33m#{index}\e[0m"
        index.succ!
      end

      # Transform the hash into the output string
      output = rows.inject('') do |n,(i,row)|
        # Fill in the empty spaces
        row = Array.new(row.keys.max - min_x + 1) {|j| row[j+min_x] or ' ' }

      n << ' ' if i % 2 == 0 # offset for even rows
      n << row.join(' ') << "\n"
      end

      say(output.chomp)
    end
  end
end
