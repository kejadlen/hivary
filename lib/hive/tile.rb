module Hive
  class Tile
    attr_accessor :location

    def empty_space?; raise NotImplementedError; end

    def initialize(location)
      @location = location
    end
  end

  class EmptySpace < Tile
    def empty_space?; true; end

    def initialize(board)
      @board = board
    end
  end
end
