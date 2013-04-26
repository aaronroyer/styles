
[String, Regexp, Symbol].each do |klass|
  klass.class_eval do

    # Associates the receiver object with a hash of properties and adds both of these as a
    # Styles::Rule to the Styles::Stylesheet that is currently being built.
    def -(properties_hash)
      $stylesheet_currently_being_built.add_rule(self, properties_hash)
    end
  end
end
