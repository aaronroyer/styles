module Styles
  module Properties
    class BackgroundColor < Base
      sub_engine :color

      VALUES = (Styles::Colors::COLOR_VALUES + [:none]).freeze
      SKIP_VALUES = [:none].freeze

      # Convert foreground colors to background
      def color_to_use
        return :no_bg_color if value == :none
        value =~ /^on_/ ? value : "on_#{value}".to_sym
      end
    end
  end
end
