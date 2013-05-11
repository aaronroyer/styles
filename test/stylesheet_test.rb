require File.expand_path('../test_helper', __FILE__)
require 'term/ansicolor'
require 'tempfile'
require 'timecop'

class StylesheetTest < MiniTest::Unit::TestCase
  def teardown
    tmp_stylesheet_files.each do |f|
      f.close
      f.unlink
    end
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

    sheet = Styles::Stylesheet.from_string(stylesheet_text)
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

  def test_raises_stylesheet_load_error_when_loading_fails
    bad_stylesheet_text = <<-STYLESHEET
      'ugh' - {
        color: green
    STYLESHEET

    assert_raises(::Styles::StylesheetLoadError) do
      Styles::Stylesheet.from_string bad_stylesheet_text
    end

    assert_raises(::Styles::StylesheetLoadError) do
      Styles::Stylesheet.new('somebogusfilenamethatdoesnotexistanywhere.rb')
    end
  end

  def test_can_create_a_stylesheet_from_a_file
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

    file = tmp_stylesheet_file(stylesheet_text)
    sheet = Styles::Stylesheet.new(file.path)
    assert_equal 3, sheet.rules.size
  end

  def test_can_reload_rules_from_a_file
    stylesheet_text = <<-STYLESHEET
      'good' - {
        color: green,
        font_weight: bold
      }

      /bad/ - {
       color: red
      }
    STYLESHEET

    file = tmp_stylesheet_file(stylesheet_text)
    sheet = Styles::Stylesheet.new(file.path)
    assert_equal 2, sheet.rules.size

    good_rule = sheet.rules.find { |rule| rule.selector == 'good' }
    bad_rule = sheet.rules.find { |rule| rule.selector == /bad/ }

    assert_equal 2, good_rule.properties.size
    color_prop = good_rule.properties.find { |p| p.class == ::Styles::Properties::Color }
    assert_equal :green, color_prop.value
    assert good_rule.properties.find { |p| p.class == ::Styles::Properties::FontWeight }

    assert 1, bad_rule.properties.size

    new_stylesheet_text = <<-NEW_STYLESHEET
      'good' - {
        color: cyan,
        text_decoration: underline,
        match_color: blue
      }

      /other/ - {
        color: yellow
      }

      :blank - {
        display: none
      }
    NEW_STYLESHEET

    File.open(file.path, 'w') { |f| f.write new_stylesheet_text }

    sheet.reload

    assert_equal 3, sheet.rules.size

    good_rule = sheet.rules.find { |rule| rule.selector == 'good' }
    assert_equal 3, good_rule.properties.size
    color_prop = good_rule.properties.find { |p| p.class == ::Styles::Properties::Color }
    assert_equal :cyan, color_prop.value
    assert good_rule.properties.find { |p| p.class == ::Styles::Properties::TextDecoration }
    assert good_rule.properties.find { |p| p.class == ::Styles::Properties::MatchColor }

    assert_nil sheet.rules.find { |rule| rule.selector == /bad/ }
    assert sheet.rules.find { |rule| rule.selector == :blank }
  end

  def test_reload_if_outdated
    stylesheet_text = <<-STYLESHEET
      'good' - {
        color: green
      }
    STYLESHEET

    new_stylesheet_text = <<-STYLESHEET
      'good' - {
        color: green
      }
      'other' - {
        color: cyan
      }
    STYLESHEET

    file = tmp_stylesheet_file(stylesheet_text)
    sheet = nil

    Timecop.freeze(File.mtime(file.path) + 5) do
      sheet = Styles::Stylesheet.new(file.path)
      assert_equal 1, sheet.rules.size
      assert !sheet.outdated?
      sheet.reload_if_outdated
      assert_equal 1, sheet.rules.size
    end

    Timecop.freeze(Time.now - 5) do
      sheet = Styles::Stylesheet.new(file.path)
    end

    File.open(file.path, 'w') { |f| f.write new_stylesheet_text }

    assert_equal 1, sheet.rules.size
    assert sheet.outdated?

    sheet.reload_if_outdated
    assert_equal 2, sheet.rules.size
  end

  def test_unrecognized_property_names
    stylesheet_text = <<-STYLESHEET
      'good' - {
        color: green,
        bogus: value,
        match_color: yellow
      }
      'other' - { display: none }
    STYLESHEET

    sheet = Styles::Stylesheet.from_string(stylesheet_text)
    assert_equal 2, sheet.rules.size
    assert_equal [:bogus], sheet.unrecognized_property_names
  end

  def test_old_rules_are_retained_when_reload_crashes
    stylesheet_text = <<-STYLESHEET
      'good' - {
        color: green,
        font_weight: bold
      }

      /bad/ - {
       color: red
      }
    STYLESHEET

    file = tmp_stylesheet_file(stylesheet_text)
    sheet = Styles::Stylesheet.new(file.path)
    assert_equal 2, sheet.rules.size
    assert sheet.rules.find { |rule| rule.selector == 'good' }
    assert sheet.rules.find { |rule| rule.selector == /bad/ }

    new_stylesheet_text = <<-NEW_STYLESHEET
      'wat' - {
        display: none
    NEW_STYLESHEET

    File.open(file.path, 'w') { |f| f.write new_stylesheet_text }

    assert_raises(::Styles::StylesheetLoadError) { sheet.reload }

    assert_equal 2, sheet.rules.size
    assert sheet.rules.find { |rule| rule.selector == 'good' }
    assert sheet.rules.find { |rule| rule.selector == /bad/ }
  end

  private

  def tmp_stylesheet_files
    @tmp_stylesheet_files ||= []
  end

  def tmp_stylesheet_file(text, name=nil)
    name ||= 'stylesheet'
    file = Tempfile.new [name, '.rb']
    file.write text
    file.close
    tmp_stylesheet_files << file
    file
  end
end
