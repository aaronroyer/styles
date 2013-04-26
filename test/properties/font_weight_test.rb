require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class BackgroundColorTest < MiniTest::Unit::TestCase
  def test_can_embolden_a_line
    test_line = 'this is a test line'

    assert_equal "#{color.bold}#{test_line}#{color.reset}",
      ::Styles::Properties::FontWeight.new(:bold).apply(test_line)

    assert_equal test_line, ::Styles::Properties::FontWeight.new(:normal).apply(test_line)
    assert_equal test_line, ::Styles::Properties::FontWeight.new(:invalid).apply(test_line)
  end

  private

  def color
    ::Term::ANSIColor
  end
end
