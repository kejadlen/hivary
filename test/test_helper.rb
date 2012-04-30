$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'simplecov'; SimpleCov.start { command_name 'MiniTest' }

require 'fivemat/minitest/autorun'

module Hive; end

class HiveTestCase < MiniTest::Unit::TestCase
  include Hive
end

# So we don't need to do mock.expect :hash everywhere.
class MiniTest::Mock
  def hash; super; end
end
