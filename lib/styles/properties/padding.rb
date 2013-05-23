module Styles
  module Properties
    class Padding < Base
      sub_engine :layout
      other_names :padding_left, :padding_right, :padding_top, :padding_bottom

      attr_reader :top, :right, :bottom, :left

      def initialize(*args)
        if args.size == 1 && args.first.is_a?(Array)
          @name = :padding
          @sub_properties = args.first
        else
          if (val = args[2]).is_a?(String)
            @name = :padding
            @sub_properties = []
            side_values = args[2].split.map(&:to_i)
            %w[top right bottom left].each_with_index do |side, idx|
              side_value = side_values[idx]
              if side_value
                @sub_properties << self.class.new(args[0], "padding_#{side}".to_sym, side_value)
              end
            end
          else
            super
            @sub_properties = nil
          end
        end
        compute_all_padding
      end

      def all_padding
        [top, right, bottom, left]
      end

      protected

      attr_reader :sub_properties

      # Hash of padding values that have been defined (nil if not defined) for internal
      # tracking and combination of sub-properties
      attr_accessor :defined_padding

      # If the value is an integer, returns that. For any other value, including the valid
      # <tt>:none</tt> value, <tt>0</tt> is returned.
      def normalized_value
        value.is_a?(Integer) ? value : 0
      end

      private

      def compute_all_padding
        @defined_padding = { top: nil, right: nil, bottom: nil, left: nil }

        if @sub_properties
          @sub_properties.each do |sub_prop|
            if sub_prop.name == :padding
              @defined_padding.merge!(sub_prop.defined_padding.dup.delete_if { |k,v| v.nil? })
            else
              @defined_padding.merge!(
                { sub_prop.name.to_s.sub(/^padding_/, '').to_sym => sub_prop.normalized_value }
              )
            end
          end
        else
          if name == :padding
            [:top, :right, :bottom, :left].each { |side| @defined_padding[side] = normalized_value }
          elsif name.to_s =~ /padding_(\w+)/
            @defined_padding[$1.to_sym] = normalized_value
          end
        end

        @defined_padding.each_pair { |side, val| set_padding(side, val) }
      end

      def set_padding(which, val)
        instance_variable_set("@#{which}".to_sym, (val.nil? ? 0 : val))
      end
    end
  end
end
