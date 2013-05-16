require 'term/ansicolor'

module Styles
  module Properties
    FOREGROUND_COLOR_VALUES = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    BACKGROUND_COLOR_VALUES = [:on_black, :on_red, :on_green, :on_yellow, :on_blue, :on_magenta, :on_cyan, :on_white]
    COLOR_VALUES = FOREGROUND_COLOR_VALUES + BACKGROUND_COLOR_VALUES

    class Base
      attr_accessor :value, :selector

      def self.sub_engines
        @sub_engines ||= []
      end

      def self.sub_engine(name)
        sub_engine_class = ::Styles::SubEngines.const_get(name.to_s.capitalize)
        sub_engines << sub_engine_class

        begin
          include sub_engine_class::PropertyMixin
        rescue NameError
          # do nothing if PropertyMixin does not exist for SubEngine
        end
      end

      def self.to_sym
        underscore(name).split('/').last.to_sym
      end

      def initialize(value, selector=nil)
        @value, @selector = value, selector
      end

      def colors
        ::Styles::Colors
      end

      private

      def self.underscore(word)
        word = word.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end
    end
  end
end
