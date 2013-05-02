module Styles
  module Properties
    class TextDecoration < Base
      # CSS value is line-through and not strikethrough, but include strikethrough as well
      VALUES = [:none, :underline, :line_through, :strikethrough, :blink]

      def apply(line)
        return line unless VALUES.include?(value) && value != :none
        "#{colors[value]}#{line.chomp}#{colors[:reset]}"
      end
    end
  end
end
