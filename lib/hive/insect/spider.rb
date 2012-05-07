require_relative 'base'

module Hive
  module Insect
    class Spider < Base
      def valid_moves
        # Remove the spider from the board for freedom of movement calculations
        self.board.delete(self)

        neighbors = self.neighbors
        moves = neighbors[:spaces] & neighbors[:insects].map {|insect| insect.neighbors[:spaces] }.flatten
        moves.map! {|move| [move] }

        until moves.first.length == 3
          move = moves.shift

          neighbors = move.last.neighbors
          (neighbors[:spaces] & neighbors[:insects].map {|insect| insect.neighbors[:spaces] }.flatten).each do |space|
            next unless self.board.can_slide?(move.last.location, space.location)
            moves << (move.dup << space) unless space == move.first # can't backtrack
          end
        end

        self.board[*self.location] = self

        moves.map {|move| move.last.location }.uniq.sort
      end
    end
  end
end
