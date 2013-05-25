module Styles
  module Properties
    class Margin < Base
      sub_engine :layout
      other_names :margin_left, :margin_right, :margin_top, :margin_bottom

      attr_reader :top, :right, :bottom, :left

      def initialize(*args)
        if args.size == 1 && args.first.is_a?(Array)
          @name = :margin
          @sub_properties = args.first
        else
          if (val = args[2]).is_a?(String)
            @name = :margin
            @sub_properties = []
            side_values = args[2].split.map do |side_value|
              side_value == 'auto' ? :auto : side_value.to_i
            end
            %w[top right bottom left].each_with_index do |side, idx|
              side_value = side_values[idx]
              if side_value
                @sub_properties << self.class.new(args[0], "margin_#{side}".to_sym, side_value)
              end
            end
          else
            super
            @sub_properties = nil
          end
        end
        compute_all_margins
      end

      def all_margins
        [top, right, bottom, left]
      end

      protected

      attr_reader :sub_properties

      # Hash of margins that have been defined (nil if not defined) for internal tracking and
      # combination of sub-properties
      attr_accessor :defined_margins

      # If the value is an integer, returns that. For any other value, including the valid
      # <tt>:none</tt> value, <tt>0</tt> is returned.
      def normalized_value
        (value.is_a?(Integer) || value == :auto) ? value : 0
      end

      private

      def compute_all_margins
        @defined_margins = { top: nil, right: nil, bottom: nil, left: nil }

        if @sub_properties
          @sub_properties.each do |sub_prop|
            if sub_prop.name == :margin
              @defined_margins.merge!(sub_prop.defined_margins.dup.delete_if { |k,v| v.nil? })
            else
              @defined_margins.merge!(
                { sub_prop.name.to_s.sub(/^margin_/, '').to_sym => sub_prop.normalized_value }
              )
            end
          end
        else
          if name == :margin
            [:top, :right, :bottom, :left].each { |side| @defined_margins[side] = normalized_value }
          elsif name.to_s =~ /margin_(\w+)/
            @defined_margins[$1.to_sym] = normalized_value
          end
        end

        @defined_margins.each_pair { |side, val| set_margin(side, val) }
      end

      def set_margin(which, val)
        instance_variable_set("@#{which}".to_sym, (val.nil? ? 0 : val))
      end
    end
  end
end
