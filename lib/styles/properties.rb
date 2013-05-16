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
].each { |property| require "styles/properties/#{property}" }
