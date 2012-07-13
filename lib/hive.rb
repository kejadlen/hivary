module Hive
  class HiveError < StandardError; end
end

require 'hive/board'
require 'hive/game'
require 'hive/player'

module Hive
  class IllegalOperation < StandardError; end

  class NullObject
    def method_missing(*args, &block)
      self
    end
  end
end

def Maybe(value)
  case value
  when nil then Hive::NullObject.new
  else value
  end
end
