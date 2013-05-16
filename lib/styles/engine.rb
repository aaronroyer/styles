require 'term/ansicolor'

module Styles

  # Takes one or more Stylesheets and applies the rules from them to lines of text.
  class Engine
    attr_reader :stylesheets

    def initialize(*stylesheets)
      @stylesheets = [stylesheets].flatten
    end

    # Process a line according to the rules that comprise all of the Stylesheets.
    #
    # For all the rules that are applicable to this line, find the last defined of each type of
    # property and apply it.
    #
    # Returns nil if the line is hidden or otherwise should not be displayed.
    def process(line)
      applicable_rules = rules.find_all { |rule| rule.applicable?(line) }

      properties_hash = {}
      applicable_rules.each do |rule|
        rule.properties.each do |property|
          properties_hash[property.class.name.downcase.to_sym] = property
        end
      end
      properties = properties_hash.values

      line_obj = ::Styles::Line.new(line, properties)

      color_sub_engine = ::Styles::SubEngines::Color.new
      layout_sub_engine = ::Styles::SubEngines::Layout.new

      [color_sub_engine, layout_sub_engine].each do |sub_engine|
        line_obj = sub_engine.process(line_obj)
        return nil if line_obj.current.nil?
      end

      line_obj.to_s
    end

    private

    def rules
      stylesheets.map(&:rules).flatten
    end

    def color
      ::Term::ANSIColor
    end
  end
end
