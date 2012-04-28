require_relative 'tile'

module Hive
  class Board
    attr_reader :insects

    def [](*location); self.insects[location]; end

    def initialize
      @insects = { [0,0] => EmptySpace.new(self) }
    end
  end
end
