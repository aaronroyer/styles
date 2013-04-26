require File.expand_path('../test_helper', __FILE__)
require 'term/ansicolor'

class StylesheetTest < MiniTest::Unit::TestCase

  def teardown
    Styles::Stylesheets.constants.each { |const| Styles::Stylesheets.send(:remove_const, const) }
  end

  def test_properties_of_later_rules_are_preferred
    hide_all_style = ':all - { display: none }'
    show_line_style = "'show' - { display: block }"

    blank_filter = Styles::Stylesheet.from_string('BlankTestStylesheet', hide_all_style).new
    assert_equal nil, blank_filter.process('just some text')

    show_filter = Styles::Stylesheet.from_string('ShowTestStylesheet', show_line_style).new
    assert_equal 'show this line', show_filter.process('show this line')

    # Now combine the rules and make sure the properties of the last one takes precedence.

    still_hidden_filter = Styles::Stylesheet.from_string(
      'StillHiddenStylesheet', "#{show_line_style}\n#{hide_all_style}").new
    assert_equal nil, still_hidden_filter.process('just some text')

    override_earlier_property_filter = Styles::Stylesheet.from_string(
      'OverrideEarlierPropertyStylesheet', "#{hide_all_style}\n#{show_line_style}").new
    assert_equal 'show this line', override_earlier_property_filter.process('show this line')
  end

  def test_rules_can_hide_lines
    filter_text = <<-FILTER_TEXT
      'ANNOYING' - {
        display: none
      }

      /hide this/ - {
        display: none
      }
    FILTER_TEXT

    filter = Styles::Stylesheet.from_string('DisplayTestStylesheet', filter_text).new

    assert_equal 'this is a line', filter.process('this is a line')
    assert_nil filter.process('THIS LINE IS ANNOYING')
    assert_nil filter.process('this line has hide this in it')
  end

  def test_rules_can_color_lines
    filter_text = <<-FILTER_TEXT
      'good' - {
        color: green
      }

      /red alert/ - {
        color: red
      }
    FILTER_TEXT

    filter = Styles::Stylesheet.from_string('ColorTestStylesheet', filter_text).new

    assert_equal "#{color.green}this is a good thing#{color.reset}", filter.process('this is a good thing')
    assert_equal "#{color.red}this is a red alert#{color.reset}", filter.process('this is a red alert')
  end

  private

  def color
    ::Term::ANSIColor
  end
end
