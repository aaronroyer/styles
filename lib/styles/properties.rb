%w[
  base
  display
  color
  background_color
  font_weight
  text_decoration
  match_color
  match_background_color
  match_font_weight
  match_text_decoration
  text_align
  padding
  margin
].each { |property| require "styles/properties/#{property}" }

module Styles
  module Properties

    def self.all_property_classes
      constants = ::Styles::Properties.constants - [:Base]
      constants.map { |con| ::Styles::Properties.const_get(con) }
    end

    def self.find_class_by_property_name(name)
      name = name.to_sym
      all_property_classes.find { |klass| klass.names.include? name }
    end

  end
end
