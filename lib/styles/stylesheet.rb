module Styles

  # Contains any Stylesheet classes created by parsing stylesheet text
  module Stylesheets
  end

  class Stylesheet

    # Create a new Stylesheet class with the given name from the given stylesheet text.
    def self.from_string(name, text)
      stylesheet = Class.new(Stylesheet)
      stylesheet.class_eval(text)
      ::Styles::Stylesheets.const_set(name, stylesheet)
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

    # Get the rules for this Stylesheet class (stored in a class instance variable)
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

    # Process a line according to the rules that comprise this Stylesheet.
    #
    # For all the rules that are applicable to this line, find the last defined of each type of
    # property and apply it.
    #
    # Returns nil if the line is hidden or otherwise should not be displayed.
    def process(line)
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
