module Styles
  module Properties
    class Width < Base
      sub_engine :layout

      def width
        value.to_i >= 0 ? value : 0
      end
    end
  end
end
