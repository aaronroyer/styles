module Styles
  module SubEngines
    class Layout < Base

      def process(line)
        layout_sub_engine_properties = extract_sub_engine_properties line.applicable_properties

        if should_hide?(line)
          line.current = nil
          return line
        end

        line
      end

      private

      def should_hide?(line)
        display_property = line.applicable_properties.find { |prop| prop.class == ::Styles::Properties::Display }
        display_property && ::Styles::Properties::Display::HIDE_VALUES.include?(display_property.value)
      end

    end
  end
end
