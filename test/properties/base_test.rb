require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class PropertyBaseTest < MiniTest::Unit::TestCase

  def test_to_sym
    assert_equal :color, ::Styles::Properties::Color.to_sym
    assert_equal :text_align, ::Styles::Properties::TextAlign.to_sym
  end

end
