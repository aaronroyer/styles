module Styles
  module Properties
    class FontWeight < Base
      VALUES = [:normal, :bold]

      strip_original_color

      def apply(line)
        value == :bold ? "#{colors[:bold]}#{line.chomp}#{colors[:reset]}" : line
      end
    end
  end
end
