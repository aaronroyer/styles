module Styles
  module Properties
    class FontWeight < Base
      sub_engine :color

      VALUES = [:normal, :bold].freeze
      SKIP_VALUES = [:normal].freeze
    end
  end
end
