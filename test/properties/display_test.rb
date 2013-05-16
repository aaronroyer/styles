require File.expand_path('../../test_helper', __FILE__)

class DisplayTest < MiniTest::Unit::TestCase
  def test_line_passes_through_with_show_values
    test_line = 'this is a test line'

    assert_equal test_line, process(:block, 'test', test_line)
    assert_equal test_line, process(true, 'test', test_line)
  end

  def test_line_hidden_with_hide_values
    test_line = 'this is a test line'

    assert_nil process(:none, 'test', test_line)
    assert_nil process(false, 'test', test_line)
  end

  private

  def process(value, selector, line)
    sub_engine = ::Styles::SubEngines::Layout.new
    line = ::Styles::Line.new(line, [::Styles::Properties::Display.new(value, selector)])
    result = sub_engine.process(line)
    result.current
  end
end
