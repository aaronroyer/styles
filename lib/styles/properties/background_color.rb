module Styles
  module Properties
    class BackgroundColor < Base
      def apply(line)
        return line unless colors.is_basic_color?(value)
        bg_color = value =~ /^on_/ ? value : "on_#{value}".to_sym
        "#{colors[bg_color]}#{line.chomp}#{colors[:reset]}"
      end
    end
  end
end
