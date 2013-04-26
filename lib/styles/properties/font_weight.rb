module Styles
  module Properties
    class FontWeight < Base
      VALUES = [:normal, :bold]

      def apply(line)
        value == :bold ? "#{color.bold}#{line.chomp}#{color.reset}" : line
      end
    end
  end
end
