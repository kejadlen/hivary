module Hive
  module Insect
    module Climber
      attr_accessor :stack

      def on_top?; not self.stack.nil?; end
      def breaks_hive?; (self.on_top?) ? false : super; end

      def valid_moves
        (self.on_top?) ? Board.neighbors(*self.location) : super
      end

      def move(location)
        tile = self.board[*location]

        super(location)

        # Uncover the insect under the insect if it is on top of the hive
        self.board[*self.stack.location] = self.stack if self.stack

        # Put the piece under the insect if we're moving on top of the hive
        self.stack = (tile.empty_space?) ? nil : tile
      end
    end
  end
end
