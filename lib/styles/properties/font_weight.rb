module Styles
  module Properties
    class FontWeight < Base
      sub_engine :color

      VALUES = [:normal, :bold].freeze
      SKIP_VALUES = [:normal].freeze

      def color_to_use
        value == :normal ? :no_bold : value
      end
    end
  end
end
