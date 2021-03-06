require 'test/test_helper'

module Nanotest
  class << self
    def failures() @@failures end
    def errors() @@errors end
    def dots() @@dots end
  end

  # don't autorun
  def at_exit() end
end
require 'nanotest'

# fixture class for nanotest mixin
class Foo
  include Nanotest
end

class TestNanotest < MiniTest::Unit::TestCase
  def self.test(name, &block)
    define_method("test_#{name.gsub(/\s/,'_')}", &block)
  end

  def teardown
    Nanotest::dots.clear
    Nanotest::failures.clear
    Nanotest::errors.clear
  end

  test "api" do
    assert_respond_to Foo.new, :assert
    assert_respond_to Nanotest, :assert
  end

  test "assertion passes" do
    Nanotest.assert { true }
    assert_equal '.', Nanotest::dots.last
    assert_empty Nanotest::failures
  end

  test "assertion fails (false)" do
    Nanotest.assert { false }
    assert_equal 'F', Nanotest::dots.last
    refute_empty Nanotest::failures
  end

  test "assertion fails (nil)" do
    Nanotest.assert { nil }
    assert_equal 'F', Nanotest::dots.last
    refute_empty Nanotest::failures
  end
  
  test "assertion raises error" do
    assert_nothing_raised { Nanotest.assert { raise 'hell' } }
    assert_equal 'E', Nanotest::dots.last
    refute_empty Nanotest::errors
  end

  test "failure message" do
    @line = __LINE__; Nanotest.assert { false }
    assert_equal 1, Nanotest::failures.size
    assert_includes Nanotest::failures, "(%s:%0.3d) assertion failed" % [__FILE__, @line]
  end
  
  test "error message" do
    @line = __LINE__; Nanotest.assert { raise RuntimeError, 'an error' }
    assert_equal 1, Nanotest::errors.size
    assert_includes Nanotest::errors, "(%s:%0.3d) assertion raised error: RuntimeError: an error" % [__FILE__, @line]
  end

  test "custom failure message, file, line" do
    Nanotest.assert('foo','bar',2) { false }
    assert_includes Nanotest::failures, "(bar:002) foo"
  end
  
  test "custom failure message, file, line with error" do
    Nanotest.assert('foo','bar',2) { raise 'hell' }
    assert_includes Nanotest::errors, "(bar:002) foo"
  end

  test "displays results" do
    Nanotest.assert { true }
    Nanotest.assert { false };                          line1 = __LINE__
    Nanotest.assert { false };                          line2 = __LINE__
    Nanotest.assert { raise RuntimeError, 'an error' }; line3 = __LINE__
    expected = <<-OUT.gsub(/^\s*/,'').strip % [__FILE__, line1, __FILE__, line2, __FILE__, line3]
      .FFE
      (%s:%0.3d) assertion failed
      (%s:%0.3d) assertion failed
      (%s:%0.3d) assertion raised error: RuntimeError: an error
    OUT
    assert_equal expected, Nanotest.results
  end

  test "displays results with no assertions" do
    assert_empty Nanotest.results.strip
  end

  test "handles origin lines that contain colons" do
    stack = ['o:hai:e:20:blah']
    Nanotest.assert('', nil, nil, stack) { false }
    assert_equal "(o:hai:e:020) ", Nanotest.failures.last

    stack = ['o:hai:e:20']
    Nanotest.assert('', nil, nil, stack) { false }
    assert_equal "(o:hai:e:020) ", Nanotest.failures.last
  end
end

