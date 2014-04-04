# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'greek_stemmer/version'

Gem::Specification.new do |spec|
  spec.name          = "greek_stemmer"
  spec.version       = GreekStemmer::VERSION
  spec.authors       = ["Tasos Stathopoulos", "Giorgos Tsiftsis"]
  spec.email         = ["stathopa@skroutz.gr", "giorgos.tsiftsis@skroutz.gr"]
  spec.summary       = %q{A simple Greek stemmer}
  spec.description   = %q{A simple Greek stemmer}
  spec.homepage      = "https://github.com/skroutz/greek_stemmer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.files.reject! { Dir['benchmarks'] }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  if RUBY_VERSION >= "2.0.0"
    spec.add_development_dependency "pry-byebug"
  else
    spec.add_development_dependency "pry"
  end
end
