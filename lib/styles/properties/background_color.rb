module Styles
  module Properties
    class BackgroundColor < Base
      VALUES = ::Styles::Properties::COLOR_VALUES

      def apply(line)
        return line unless VALUES.include?(value)
        bg_color = value =~ /^on_/ ? value : "on_#{value}"
        "#{color.send(bg_color)}#{line.chomp}#{color.reset}"
      end
    end
  end
end
