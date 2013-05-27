require 'term/ansicolor'

module Styles
  module Properties
    class Base
      attr_accessor :selector, :name, :value

      def self.sub_engines
        @sub_engines ||= []
      end

      # Macro to specify a sub-engine that this property is processed by
      def self.sub_engine(name)
        sub_engine_class = ::Styles::SubEngines.const_get(camelize(name.to_s))
        sub_engines << sub_engine_class

        begin
          include sub_engine_class::PropertyMixin
        rescue NameError
          # do nothing if PropertyMixin does not exist for SubEngine
        end
      end

      # The name of this property, for use in stylesheets, as a Symbol
      def self.to_sym
        underscore(name).split('/').last.to_sym
      end

      # Macro to specify other names that a property class uses, besides the main +to_sym+ version
      def self.other_names(*names)
        @other_names = names
        @names = self.names
      end

      def self.names
        @names ||= [to_sym, instance_variable_get('@other_names')].flatten.compact
      end

      def self.multiple_names?
        names.size > 1
      end

      def initialize(selector, name, value)
        @selector, @name, @value = selector, name, value
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

      def self.camelize(word)
        word.capitalize.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }
      end
    end
  end
end
