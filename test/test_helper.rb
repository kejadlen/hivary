$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'fivemat/minitest/autorun'

module Hive; end

class HiveTestCase < MiniTest::Unit::TestCase
  include Hive
end
