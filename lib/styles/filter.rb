module Styles
  # Contains any filter classes created by parsing a stylesheet
  module Filters
  end

  class Filter
    def self.from_stylesheet(name, text)
      filter = Class.new(Filter)
      filter.class_eval(text)
      ::Styles::Filters.const_set name, filter
    end

    # Supports the DSL for stylesheets, making them more attractive and CSS-y by allowing
    # property values to be specified like this
    #
    #   color: red
    #
    # instead of like this
    #
    #   color: :red
    #
    def self.method_missing(name)
      name
    end

    # Get the rules for this Filter class (stored in an instance variable of the class)
    def self.rules
      @rules ||= []
    end

    def self.add_rule(selector, properties_hash)
      rules << Rule.new(selector, properties_hash)
    end

    def self.inherited(subclass)
      $stylesheet_currently_being_built = subclass
    end

    def rules
      self.class.rules
    end

    # Filter a line according to the rules that comprise this Filter.
    #
    # For all the rules that are applicable to this line, find the last defined of each type of
    # property and apply it.
    #
    # Returns nil if the line is hidden or otherwise should not be displayed.
    def filter(line)
      applicable_rules = rules.find_all { |rule| rule.applicable?(line) }

      properties = {}
      applicable_rules.each do |rule|
        rule.properties.each do |property|
          properties[property.class.name.downcase.to_sym] = property
        end
      end

      properties.values.inject(line.dup) do |line_before, property|
        line_after = property.apply(line_before)
        return nil unless line_after
        line_after
      end
    end
  end
end
