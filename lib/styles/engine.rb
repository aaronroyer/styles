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

      simple_properties = {}
      multiple_names_properties = {}
      applicable_rules.each do |rule|
        rule.properties.each do |property|
          if property.class.multiple_names?
            (multiple_names_properties[property.class.to_sym] ||= []) << property
          else
            simple_properties[property.class.to_sym] = property
          end
        end
      end

      properties = simple_properties.values

      multiple_names_properties.keys.each do |basic_name|
        props = multiple_names_properties[basic_name]
        prop_class = props.first.class
        properties << prop_class.new(props)
      end

      line_obj = ::Styles::Line.new(line, properties)

      sub_engines.each do |sub_engine|
        line_obj = sub_engine.process(line_obj)
        return nil if line_obj.text.nil?
      end

      line_obj.to_s
    end

    private

    # Returns instances SubEngines in the order that they should be used in processing.
    def sub_engines
      @sub_engines ||= begin
        [
          ::Styles::SubEngines::PreProcessor.new,
          ::Styles::SubEngines::Color.new,
          ::Styles::SubEngines::Layout.new
        ]
      end
    end

    def rules
      stylesheets.map(&:rules).flatten
    end

    def color
      ::Term::ANSIColor
    end
  end
end
