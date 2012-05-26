require 'delegate'

require_relative '../hive'

module Hive
  class Stack < Delegator
    def __getobj__; @source; end

    def initialize(*args)
      @source = args
    end

    def top; @source.last; end
  end
end
