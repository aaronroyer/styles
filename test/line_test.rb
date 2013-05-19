require File.expand_path('../test_helper', __FILE__)
require 'term/ansicolor'

class LineTest < MiniTest::Unit::TestCase
  include Styles

  def test_can_update
    original = 'this is a line'
    updated = 'this is an updated line'
    line = Line.new original
    assert_equal original, line.to_s
    assert_equal original, line.text

    line.text = updated
    assert_equal updated, line.to_s
    assert_equal updated, line.text
    assert_equal original, line.original

    line = Line.new original
    line.text = updated
    assert_equal updated, line.to_s
    assert_equal original, line.original
  end
end
