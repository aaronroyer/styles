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

      # TODO: clean up SubEngine processing
      color_sub_engine_properties, other_properties = properties.partition do |prop|
        prop.class.ancestors.include? Styles::SubEngines::Color::PropertyMixin
      end

      color_sub_engine = Styles::SubEngines::Color.new
      color_sub_engine_processed_line = color_sub_engine.process(line_obj).to_s

      other_properties.inject(color_sub_engine_processed_line) do |line_before, property|
        line_after = property.apply(line_before)
        return nil unless line_after
        line_after
      end
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
