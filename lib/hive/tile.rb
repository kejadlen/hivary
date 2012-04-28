require_relative 'board'

module Hive
  class Tile
    def empty_space?; self.class == EmptySpace; end
    def to_s; self.class.to_s.split('::').last; end
  end

  class EmptySpace < Tile
    attr_reader :board

    def initialize(board); @board = board; end
  end
end
