# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'styles/version'

Gem::Specification.new do |gem|
  gem.name          = 'styles'
  gem.version       = Styles::VERSION
  gem.authors       = ['Aaron Royer']
  gem.email         = ['aaronroyer@gmail.com']
  gem.description   = %q{plain text stylesheets}
  gem.summary       = %q{A utility for processing text that provides a Ruby DSL leveraging CSS concepts}
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'term-ansicolor', '~> 1.1.0'

  gem.add_development_dependency 'timecop'
end
