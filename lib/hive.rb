require_relative 'hive/board'
require_relative 'hive/game'
require_relative 'hive/player'

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
