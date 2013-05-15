module Styles
  class Line
    attr_accessor :applicable_properties
    attr_reader :original
    attr_writer :current

    def initialize(line, properties=nil)
      @original = line
      @original.freeze
      @applicable_properties = properties

      @current = nil
    end

    def current
      (@current || @original).dup
    end
    alias :to_s :current

    alias :update :current=
  end
end
