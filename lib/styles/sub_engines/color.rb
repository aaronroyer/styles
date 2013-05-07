module Styles
  module SubEngines
    class Color
      # Get the property type (:line or :match) of a property instance
      def self.property_type(property)
        klass = property.class
        if klass.constants.include?(:COLOR_PROPERTY_TYPE) && klass::COLOR_PROPERTY_TYPE == :match
          :match
        else
          :line
        end
      end

      def process(properties, line)
        line_properties, match_properties = properties.partition { |p| self.class.property_type(p) == :line }

        line_colors = get_line_colors(line_properties)

        colored_line = line.dup.chomp

        match_properties.each do |prop|
          next unless prop.valid_value?
          if prop.selector.is_a? String
            colored_line = apply_string_match_property(prop, line_colors, colored_line)
          elsif prop.selector.is_a? Regexp
            colored_line = apply_regex_match_property(prop, line_colors, colored_line)
          end
        end

        line_colors.any? ? "#{colors[line_colors]}#{colored_line}#{colors[:reset]}" : colored_line
      end

      private

      def get_line_colors(line_properties)
        line_properties.map(&:color_to_use).reject { |c| !colors.valid?(c) }.sort
      end

      # Apply a match property that has a String selector to the given line. Takes into account
      # line property colors and makes sure the rest of the line has those applied to it.
      def apply_string_match_property(property, line_colors, line)
        before_match_colors, after_match_colors = colors.line_substring_color_transitions(
          line_colors, property.color_to_use
        )
        line.gsub(property.selector, "#{before_match_colors}\\0#{after_match_colors}")
      end

      def apply_regex_match_property(property, line_colors, line)
        selector, value = property.selector, property.value
        if value.is_a? Array
          return line unless selector.is_a?(Regexp)
          apply_colors_to_multiple_matches(property, line_colors, line)
        elsif value.is_a? Symbol
          before_match_colors, after_match_colors = colors.line_substring_color_transitions(
            line_colors, property.color_to_use
          )
          line.gsub(selector) { |match| "#{before_match_colors}#{match}#{after_match_colors}" }
        else
          line
        end
      end

      # Use the Regexp selector to determine match groups on the given line. Then apply the array
      # of colors to the each match group, first color to first group and so on. Ignore the last
      # match groups if they do not have corresponding colors and vice versa.
      #
      # If there are color that should be applied to the entire line then make sure to turn them
      # off before applying match colors and back on after the match.
      def apply_colors_to_multiple_matches(property, line_colors, line)
        selector, match_colors = property.selector, [property.color_to_use].flatten
        match_data = selector.match(line)
        return line unless match_data && (match_data.size > 1)
        colored_line = line.dup

        offsets = (1...(match_data.size)).to_a.map { |idx| match_data.offset(idx) }

        # Work backward through the matches because working forward would throw off indicies.
        # Determine the original index of the match and apply the corresponding color. If we
        # do not have enough colors for the last match(es) then skip them.
        # TODO: clean this up, it just feels hacky
        offsets.reverse.each_with_index do |offset, index|
          orig_match_index = offsets.size - index - 1
          match_color = match_colors[orig_match_index]
          next unless match_color

          before_match_colors, after_match_colors = colors.line_substring_color_transitions(
            line_colors, match_color
          )

          beg_idx, end_idx = offset
          colored_line.insert(end_idx, after_match_colors)
          colored_line.insert(beg_idx, before_match_colors)
        end

        colored_line
      end

      def colors
        ::Styles::Colors
      end

      module PropertyMixin
        def apply(line)
          ::Styles::SubEngines::Color.new.process([self], line)
        end

        # Can be overridden if the color to use should be derived differently
        def color_to_use
          value
        end

        def valid_value?
          self.class::VALUES.include?(value)
        end
      end
    end
  end
end
