require File.expand_path('../../test_helper', __FILE__)

class FunctionTest < MiniTest::Unit::TestCase
  def setup
    @sub_engine = ::Styles::SubEngines::PreProcessor.new 
  end

  def test_all_callables_work
    test_line = 'this is a line'
    assert_equal test_line, process('line', :function, ->(line) { line }, test_line)
    assert_equal test_line, process('line', :function, Proc.new {|line| line }, test_line)
    assert_equal test_line, process('line', :function, proc {|line| line }, test_line)
  end

  def test_arbitrary_functions
    test_line = 'this is a line'
    assert_equal nil, process('line', :function, ->(line) { line.include?('this') ? nil : line }, test_line)
    assert_equal test_line.upcase, process('line', :function, ->(line) { line.upcase }, test_line)
  end

  private

  def process(selector, property_name, value, line)
    line = ::Styles::Line.new(line, [::Styles::Properties::Function.new(selector, property_name, value)])
    result = @sub_engine.process(line)
    result.text
  end
end
