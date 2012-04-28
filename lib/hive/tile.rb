module Hive
  class Tile
    attr_accessor :location

    def initialize(location)
      @location = location
    end
  end

  class EmptySpace < Tile
    def initialize(board)
      @board = board
    end
  end
end
