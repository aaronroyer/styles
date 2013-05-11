
[String, Regexp, Symbol].each do |klass|
  klass.class_eval do

    # Associates the receiver object with a hash of properties and adds the
    # receiver and properties to the array of rules being parsed, in the global
    # variable <tt>$current_stylesheet_rules</tt>.
    def -(properties_hash)
      $current_stylesheet_rules << [self, properties_hash]
    end
  end
end
