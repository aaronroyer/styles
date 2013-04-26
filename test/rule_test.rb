require File.expand_path('../test_helper', __FILE__)
require 'term/ansicolor'

class RuleTest < MiniTest::Unit::TestCase
  def test_colored_lines_do_not_cause_false_positives
    line = "#{color.green}This is green!#{color.reset}"
    properties = { display: :none }
    string_rule = Styles::Rule.new('32', properties)
    regex_rule = Styles::Rule.new(/\d\d/, properties)

    assert !string_rule.applicable?(line), 'string selector does not match against color code'
    assert !regex_rule.applicable?(line), 'regex selector does not match against color code'
  end

  def test_colored_lines_do_not_cause_false_negatives
    line = "I am ec#{color.yellow}static#{color.reset} right now"
    properties = { display: :none }
    string_rule = Styles::Rule.new('ecstatic', properties)
    regex_rule = Styles::Rule.new(/e\w+c/, properties)

    assert string_rule.applicable?(line), 'string selector does not match against color code'
    assert regex_rule.applicable?(line), 'regex selector does not match against color code'
  end

  private

  def color
    ::Term::ANSIColor
  end
end
