require File.expand_path('../../test_helper', __FILE__)

class DisplayTest < MiniTest::Unit::TestCase
  def test_line_passes_through_with_show_values
    test_line = 'this is a test line'

    assert_equal test_line, ::Styles::Properties::Display.new(:block).apply(test_line)
    assert_equal test_line, ::Styles::Properties::Display.new(true).apply(test_line)
  end

  def test_line_hidden_with_hide_values
    test_line = 'this is a test line'

    assert_nil ::Styles::Properties::Display.new(:none).apply(test_line)
    assert_nil ::Styles::Properties::Display.new(false).apply(test_line)
  end
end
