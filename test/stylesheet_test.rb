require File.expand_path('../test_helper', __FILE__)
require 'term/ansicolor'

class StylesheetTest < MiniTest::Unit::TestCase
  def teardown
    Styles::Stylesheets.constants.each { |const| Styles::Stylesheets.send(:remove_const, const) }
  end

  def test_can_create_a_stylesheet_from_a_string
    stylesheet_text = <<-STYLESHEET
      'good' - {
        color: green
      }

      /bad/ - {
       color: red
      }

      :blank - {
        display: none
      }
    STYLESHEET

    sheet = Styles::Stylesheet.from_string('TestSheet', stylesheet_text)
    assert_equal 3, sheet.rules.size

    rules = {}
    ['good', /bad/, :blank].each do |selector|
      rules[selector] = sheet.rules.find { |rule| rule.selector == selector }
    end

    good_prop = rules['good'].properties.first
    assert_equal Styles::Properties::Color, good_prop.class
    assert_equal :green, good_prop.value

    bad_prop = rules[/bad/].properties.first
    assert_equal Styles::Properties::Color, bad_prop.class
    assert_equal :red, bad_prop.value

    blank_prop = rules[:blank].properties.first
    assert_equal Styles::Properties::Display, blank_prop.class
    assert_equal :none, blank_prop.value
  end
end
