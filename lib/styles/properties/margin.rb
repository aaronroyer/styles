module Styles
  module Properties
    class Margin < Base
      sub_engine :layout
      other_names :margin_left, :margin_right, :margin_top, :margin_bottom

      attr_reader :top, :right, :bottom, :left

      def initialize(*args)
        if args.size == 1 && args.first.is_a?(Array)
          @sub_properties = args.first
        else
          super
          @sub_properties = nil
        end
        compute_all_margins
      end

      def all_margins
        [top, right, bottom, left]
      end

      protected

      # If the value is an integer, returns that. For any other value, including the valid
      # <tt>:none</tt> value, <tt>0</tt> is returned.
      def normalized_value
        value.is_a?(Integer) ? value : 0
      end

      private

      def compute_all_margins
        if @sub_properties
          set_all_margins(0)

          @sub_properties.each do |sub_prop|
            if sub_prop.name == :margin
              set_all_margins(sub_prop.normalized_value)
            else
              set_margin(sub_prop.name.to_s.sub(/^margin_/, ''), sub_prop.normalized_value)
            end
          end
        else
          set_all_margins(name == :margin ? normalized_value : 0)
          if name.to_s =~ /margin_(\w+)/
            set_margin($1, normalized_value)
          end
        end
      end

      def set_all_margins(val)
        @top = @right = @bottom = @left = val
      end

      def set_margin(which, val)
        instance_variable_set("@#{which}".to_sym, val)
      end
    end
  end
end
