module Styles
  module Properties
    class Padding < Base
      sub_engine :layout
      other_names :padding_left, :padding_right, :padding_top, :padding_bottom

      attr_reader :top, :right, :bottom, :left

      def initialize(*args)
        if args.size == 1 && args.first.is_a?(Array)
          @sub_properties = args.first
        else
          super
          @sub_properties = nil
        end
        compute_all_padding
      end

      def all_padding
        [top, right, bottom, left]
      end

      # If the value is an integer, returns that. For any other value, including the valid
      # <tt>:none</tt> value, <tt>0</tt> is returned.
      def normalized_value
        value.is_a?(Integer) ? value : 0
      end

      private

      def compute_all_padding
        if @sub_properties
          set_all_padding(0)

          @sub_properties.each do |sub_prop|
            if sub_prop.name == :padding
              set_all_padding(sub_prop.normalized_value)
            else
              set_padding(sub_prop.name.to_s.sub(/^padding_/, ''), sub_prop.normalized_value)
            end
          end
        else
          set_all_padding(name == :padding ? normalized_value : 0)
          if name.to_s =~ /padding_(\w+)/
            set_padding($1, normalized_value)
          end
        end
      end

      def set_all_padding(val)
        @top = @right = @bottom = @left = val
      end

      def set_padding(which, val)
        instance_variable_set("@#{which}".to_sym, val)
      end
    end
  end
end
