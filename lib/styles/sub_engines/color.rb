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

        line_color_codes = compute_line_color_codes(line_properties)

        colored_line = line.dup.chomp

        colored_line = match_properties.inject(colored_line) do |updated_line, prop|
          if prop.selector.is_a? String
            apply_string_match_property(prop, line_color_codes, updated_line)
          elsif prop.selector.is_a? Regexp
            apply_regex_match_property(prop, line_color_codes, updated_line)
          else
            # No support for Symbol selectors
            colored_line
          end
        end

        line_color_codes ? "#{line_color_codes}#{colored_line}#{colors[:reset]}" : colored_line
      end

      private

      def compute_line_color_codes(line_properties)
        line_properties.reject! { |p| !p.valid_value? || p.class::SKIP_VALUES.include?(p.value) }
        unless line_properties.empty?
          line_color_codes = line_properties.map(&:color_to_use).sort.map { |color| colors[color] }.join
        end
        line_color_codes
      end

      # Apply a match property that has a String selector to the given line. Takes into account
      # line property color codes and makes sure the rest of the line has those applied to it.
      def apply_string_match_property(property, line_color_codes, line)
        color = [property.value].flatten.first
        reset = line_color_codes ? colors[:reset] : '' # Only reset if there are colors to reset
        line.gsub(property.selector, "#{reset}#{colors[color]}\\0#{colors[:reset]}#{line_color_codes}")
      end

      def apply_regex_match_property(property, line_color_codes, line)
        selector, value = property.selector, property.value
        if value.is_a? Array
          return line unless selector.is_a?(Regexp)
          apply_colors_to_multiple_matches(property, line_color_codes, line)
        elsif value.is_a? Symbol
          reset = line_color_codes ? colors[:reset] : '' # Only reset if there are colors to reset
          line.gsub(selector) { |match| "#{reset}#{colors[value]}#{match}#{colors[:reset]}#{line_color_codes}" }
        else
          line
        end
      end

      # Use the Regexp selector to determine match groups on the given line. Then apply the array
      # of colors to the each match group, first color to first group and so on. Ignore the last
      # match groups if they do not have corresponding colors and vice versa.
      #
      # If there are color codes that should be applied to the entire line then make sure to turn
      # them off before applying match colors and back on after the match.
      def apply_colors_to_multiple_matches(property, line_color_codes, line)
        before_match_codes, after_match_codes = if line_color_codes && !line_color_codes.empty?
          [colors[:reset], colors[:reset] + line_color_codes]
        else
          ['', colors[:reset]]
        end

        selector, match_colors = property.selector, [property.value].flatten
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

          beg_idx, end_idx = offset
          colored_line.insert(end_idx, after_match_codes)
          colored_line.insert(beg_idx, "#{before_match_codes}#{colors[match_color]}")
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
