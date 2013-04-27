module Styles
  module Properties
    class TextDecoration < Base
      # CSS value is line-through and not strikethrough, but include strikethrough as well
      VALUES = [:none, :underline, :line_through, :strikethrough, :blink]

      # Map CSS-style value to ANSI code name, where they are different
      CSS_TO_ANSI_VALUES = {
        :line_through => :strikethrough
      }

      def apply(line)
        return line unless VALUES.include?(value) && value != :none
        ansi_value = CSS_TO_ANSI_VALUES[value] || value
        "#{color.send(ansi_value)}#{line.chomp}#{color.reset}"
      end
    end
  end
end
