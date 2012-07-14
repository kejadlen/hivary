require 'hive/insect/base'

module Hive
  module Insect
    class Spider < Base
      def valid_moves
        moves = super
        return moves if moves.empty?

        # Remove the spider and don't replace it with an empty space (so
        # it doesn't affect the movement calculation)
        self.board.source.delete(self.location)

        moves &= self.neighbors[:insects].inject([]) {|ary,insect| ary + insect.neighbors[:spaces] }
        moves = moves.select {|move| self.board.can_slide?(self.location, move) }
        moves.map! {|move| [move] }

        until moves.empty? or moves.first.length == 3
          move = moves.shift

          neighbors = self.board.neighbors(*move.last)
          spaces = neighbors[:spaces] & neighbors[:insects].inject([]) {|ary,insect| ary + insect.neighbors[:spaces] }
          spaces.each do |space|
            next unless self.board.can_slide?(move.last, space)
            moves << (move.dup << space) unless space == move.first # can't backtrack
          end
        end

        # Replace the spider
        self.board[*self.location] = self

        moves.map(&:last).uniq.sort
      end
    end
  end
end
