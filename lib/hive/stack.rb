require 'delegate'

require_relative '../hive'

module Hive
  class Stack < Delegator
    def __getobj__; @source; end

    attr_accessor :location

    def initialize(location=nil, *args)
      @source = args
      @location = location
    end

    def top; @source.last; end
  end
end
