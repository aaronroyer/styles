module Styles
  module SubEngines
    class Color
      module PropertyMixin
        def apply(line)
          klass = self.class
          if klass.constants.include?(:SKIP_VALUES) && klass::SKIP_VALUES.include?(value)
            line
          elsif has_valid_value?
            if klass.constants.include?(:COLOR_PROPERTY_TYPE) && klass::COLOR_PROPERTY_TYPE == :match
              apply_to_matches(line)
            else
              apply_to_line(line)
            end
          else
            line
          end
        end

        # Can be overridden if the color to use should be derived differently
        def color_to_use
          value
        end

        private

        def apply_to_line(line)
          "#{colors[color_to_use]}#{line.chomp}#{colors[:reset]}"
        end

        def apply_to_matches(line)
          if value.is_a? Array
            return line unless selector.is_a?(Regexp)
            apply_colors_to_multiple_matches(line, value.dup)
          elsif value.is_a? Symbol
            line.gsub(selector) { |match| "#{colors[value]}#{match}#{colors[:reset]}" }
          else
            line
          end
        end

        # Use the regexp selector to determine match groups on the given line. Then apply the array
        # of colors to the each match group, first color to first group and so on. Ignore the last
        # match groups that do not have a corresponding color and vice versa.
        def apply_colors_to_multiple_matches(line, match_colors)
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
            colored_line.insert(end_idx, colors[:reset])
            colored_line.insert(beg_idx, colors[match_color])
          end

          colored_line
        end

        def has_valid_value?
          if respond_to?(:valid_value?)
            valid_value?
          else
            self.class::VALUES.include?(value)
          end
        end
      end

      def process(properties, line)
        #
      end
    end
  end
end
