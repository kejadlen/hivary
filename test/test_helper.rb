$LOAD_PATH.unshift('../../lib', __FILE__)

require 'fivemat/minitest/autorun'

module Hive; end

class HiveTestCase < MiniTest::Unit::TestCase
  include Hive
end
