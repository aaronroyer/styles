require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class ColorSubEngineTest < MiniTest::Unit::TestCase
  def test_can_render_color_and_match_color_correctly
    sub_engine = Styles::SubEngines::Color.new
  end

  private

  def color
    ::Term::ANSIColor
  end
end
