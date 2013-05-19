module Styles
  class Line
    attr_accessor :applicable_properties, :top, :right, :bottom, :left
    attr_reader :original
    attr_writer :text

    def initialize(line, properties=nil)
      @original = line
      @original.freeze
      @applicable_properties = properties

      @text = @original.dup
    end

    # The current content of the line, possibly already altered by processing. By content we mean
    # the line without additional layout characters (margin, padding, border) being applied around
    # it. This does, however, include color information that may have been added.
    def text
      @text.nil? ? nil : @text.dup
    end

    # The line's main text content surrounded by any extra layout characters that may have been
    # applied (margin, padding, border). When processing is complete this represents the complete
    # result to be written to the output stream.
    def to_s
      return '' unless text
      bottom_and_newline = "\n#{bottom}" if bottom && !bottom.empty?
      "#{top}#{left}#{text}#{right}#{bottom_and_newline}"
    end

    def total_width
      colors.uncolor("#{left}#{text}#{right}").size
    end

    def prop(property_name)
      prop_name = property_name.to_sym
      applicable_properties.find { |prop| prop.class.to_sym == prop_name }
    end

    def prop?(property_name)
      !!prop(property_name)
    end

    private

    def colors
      ::Styles::Colors
    end
  end
end
