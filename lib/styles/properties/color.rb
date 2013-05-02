module Styles
  module Properties
    class Color < Base
      strip_original_color

      def apply(line)
        return line unless value_valid?
        return "#{colors[:reset]}#{line}" if value == :none
        "#{start_color_codes}#{line.chomp}#{colors[:reset]}"
      end

      private

      def value_valid?
        return true if value == :none
        !!start_color_codes
      end

      def start_color_codes
        @start_color_codes ||= colors[value]
      end
    end
  end
end
