require 'minitest/autorun'

class Foo
  def initialize(obj)
    @obj = obj
  end

  def bar?
    !!@obj.baz
  end
end

describe Foo do
  describe '#bar?' do
    it 'should return true and false correctly' do
      obj = MiniTest::Mock.new
      foo = Foo.new(obj)

      obj.expect :baz, nil
      foo.bar?.must_equal false

      obj.expect :baz, 1
      foo.bar?.must_equal true

      obj.verify
    end
  end
end
