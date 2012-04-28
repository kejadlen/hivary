require 'test_helper'

require 'hive/insect/base'

class TestBase < HiveTestCase
  def setup
    @alice = MiniTest::Mock.new
    @insect = Insect::Base.new(@alice)
  end

  def test_init
    assert_equal @alice, @insect.player
    assert_nil @insect.location
  end

  def test_played
    refute @insect.played?

    @insect.location = [0,0]

    assert @insect.played?
  end
end
