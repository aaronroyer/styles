%w[
  base
  display
  color background_color match_color
  font_weight text_decoration
]
.each { |property| require "styles/properties/#{property}" }
