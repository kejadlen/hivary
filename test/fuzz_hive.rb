require 'logger'

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'hive'

module Hive
  class Fuzzer
    attr_reader :logger
    attr_reader :alice, :bob, :game

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO

      @alice = Player.new('Alice')
      @bob = Player.new('Bob')
      @game = Game.new

      [@alice, @bob].each {|player| player.join_game(@game) }
      @game.start
    end

    def start
      until @game.over?
        @logger.debug('New iteration')

        insect,locations = @game.current_player.legal_insects.sample
        location = locations.sample

        @logger.debug(@game.board.source)
        @logger.info("\n#{@game.board.to_s}")
        @logger.info("Move: #{insect} to #{location}")

        @game.current_player.move(insect, location)
      end
      @logger.info("\n#{@game.board.to_s}")
    end
  end
end

if $0 == __FILE__
  begin
    f = Hive::Fuzzer.new
    f.logger.level = Logger::INFO
    f.start
  rescue Exception => e
    require 'pry'; binding.pry
  end
end
