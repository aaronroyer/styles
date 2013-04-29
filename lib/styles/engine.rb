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

      line = preprocess(line, properties)

      properties.inject(line.dup) do |line_before, property|
        line_after = property.apply(line_before)
        return nil unless line_after
        line_after
      end
    end

    private

    def rules
      @rules ||= stylesheets.map(&:rules).flatten
    end

    def preprocess(line, properties)
      if properties.any? { |p| p.class.strip_original_color? }
        color.uncolor line
      else
        line
      end
    end

    def color
      ::Term::ANSIColor
    end
  end
end
