require 'term/ansicolor'

module Styles
  class Rule

    # Special Selectors are Symbols that describe common special cases.
    SPECIAL_SELECTORS = {
      blank: /^\s*$/,
      empty: /^$/,
      any: /^/,
      all: /^/ # Synonym of :any
    }

    attr_accessor :selector, :properties, :unrecognized_properties

    def initialize(selector, properties_hash)
      @selector = selector
      @unrecognized_properties = {}

      @properties = properties_hash.keys.map do |name|
        property_class = ::Styles::Properties.find_class_by_property_name(name)
        if property_class
          property_class.new(selector, name, properties_hash[name])
        else
          unrecognized_properties[name] = properties_hash[name]
          nil
        end
      end.compact
    end

    # Indicates whether this Rule is applicable to the given line, according to the selector. You
    # could say the selector 'matches' the line for an applicable rule.
    #
    # A String selector matches if it appears anywhere in the line.
    # A Regexp selector matches if it matches the line.
    #
    # ANSI color codes are ignored when matching to avoid false positives or negatives.
    def applicable?(line)
      uncolored_line = color.uncolor(line.chomp)
      case selector
        when String
          uncolored_line.include?(selector)
        when Regexp
          selector.match(uncolored_line)
        when Symbol
          SPECIAL_SELECTORS[selector].match(uncolored_line)
        else
          false
      end
    end

    # Apply the rule to the given line
    #
    # If the line is nil then it has been hidden before this rule has been applied. Just return
    # nil and leave it as hidden.
    def apply(line)
      return nil if line.nil?
      properties.inject(line.dup) {|result, property| property.apply(result) }
    end

    private

    def color
      ::Term::ANSIColor
    end
  end
end
