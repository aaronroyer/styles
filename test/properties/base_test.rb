require File.expand_path('../../test_helper', __FILE__)

class BaseTest < MiniTest::Unit::TestCase
  def test_valid_values_are_provided
    expected_valid_values = [:block, :inline, :inline_block, true, :none, false]
    valid_values = Styles::Properties::Display.valid_values

    assert_equal expected_valid_values.length, valid_values.length
    expected_valid_values.each {|val| assert valid_values.include?(val) }
  end
end
