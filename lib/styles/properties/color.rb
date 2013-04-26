require 'term/ansicolor'

module Styles
  module Properties
    class Color < Base
      VALUES = ::Term::ANSIColor.attributes

      def apply(line)
        return line unless value_valid?
        "#{start_color_codes}#{line.chomp}#{color.reset}"
      end

      private

      def value_valid?
        !!start_color_codes
      end

      def start_color_codes
        @start_color_codes ||= uncached_start_color_codes
      end

      def uncached_start_color_codes
        return color.send(value) if VALUES.include?(value)

        if value.to_s =~ /(\w+)_on_(\w+)/
          colors = [$1.to_sym, "on_#{$2}".to_sym]
          if colors.all? { |c| VALUES.include? c }
            return colors.map { |c| color.send(c) }.join
          end
        end

        nil
      end

      def color
        ::Term::ANSIColor
      end
    end
  end
end
