module Styles
  module Properties
    class MatchColor < Base
      VALUES = ::Term::ANSIColor.attributes

      strip_original_color

      def apply(line)
        if value.is_a? Array
          return line unless selector.is_a?(Regexp) && value.all? { |a_color| VALUES.include?(a_color) }
          apply_colors_to_matches(line, value.dup)
        elsif value.is_a? Symbol
          return line unless VALUES.include?(value)
          line.gsub(selector) { |match| "#{color.send(value)}#{match}#{color.reset}" }
        else
          line
        end
      end

      private

      # Use the regexp selector to determine match groups on the given line. Then apply the array
      # of colors to the each match group, first color to first group and so on. Ignore the last
      # match groups that do not have a corresponding color and vice versa.
      def apply_colors_to_matches(line, colors)
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
          match_color = colors[orig_match_index]
          next unless match_color

          beg_idx, end_idx = offset
          colored_line.insert(end_idx, color.reset)
          colored_line.insert(beg_idx, color.send(match_color))
        end
        
        colored_line
      end
    end
  end
end
