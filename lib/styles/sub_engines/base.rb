module Styles
  module SubEngines
    class Base

      private

      def extract_sub_engine_properties(properties)
        properties.select { |prop| prop.class.sub_engines.include? self.class }
      end

      def colors
        ::Styles::Colors
      end
    end
  end
end
