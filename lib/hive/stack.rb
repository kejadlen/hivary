require 'delegate'

require 'hive'

module Hive
  class Stack < Delegator
    def __getobj__; @source; end

    attr_accessor :location

    def initialize(*location)
      @source = []
      @location = location
    end

    def top; @source.last; end
  end
end
