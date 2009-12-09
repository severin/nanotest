require 'minitest/autorun'
require 'nanotest'
begin
  require 'redgreen'
  require 'phocus'
rescue LoadError, RuntimeError
end

class MiniTest::Unit::TestCase
  def self.test(name, &block)
    define_method("test_#{name.gsub(/\s/,'_').downcase}", &block)
  end
end

module MiniTest::Assertions
  def assert_nothing_raised()
    begin
      yield
      return true
    rescue Exception => e
      raise MiniTest::Assertion, "No error expected but got #{e.class}: #{e.message}"
    end
  end
end
