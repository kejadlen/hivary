module Hive
  class Tile
    attr_accessor :location

    def empty_space?; raise NotImplementedError; end

    def initialize(location)
      @location = location
    end

    def neighbors
      neighbors = Board.neighbors(*self.location).map {|location| self.board[*location] }.compact
      spaces,insects = neighbors.partition {|neighbor| neighbor.empty_space? }
      { spaces:spaces, insects:insects }
    end

    def to_s; "<##{self.class} #{self.location}>"; end
  end

  class EmptySpace < Tile
    attr_accessor :board

    def empty_space?; true; end

    def initialize(board, location)
      super(location)
      @board = board
    end
  end
end
