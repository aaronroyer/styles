require File.expand_path('../../test_helper', __FILE__)

class DisplayTest < MiniTest::Unit::TestCase
  def test_line_passes_through_with_show_values
    test_line = 'this is a test line'

    assert_equal test_line, process('test', :block, test_line)
    assert_equal test_line, process('test', true, test_line)
  end

  def test_line_hidden_with_hide_values
    test_line = 'this is a test line'

    assert_nil process('test', :none, test_line)
    assert_nil process('test', false, test_line)
  end

  private

  def process(selector, value, line)
    sub_engine = ::Styles::SubEngines::Layout.new
    line = ::Styles::Line.new(line, [::Styles::Properties::Display.new(selector, :display, value)])
    result = sub_engine.process(line)
    result.text
  end
end
