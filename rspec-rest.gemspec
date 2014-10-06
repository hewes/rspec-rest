# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/rest/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-rest"
  spec.version       = Rspec::Rest::VERSION
  spec.authors       = ["hewes"]
  spec.email         = ["hrysk1986@gmail.com"]
  spec.summary       = %q{Add helper and matcher for testing RESTful API Server}
  spec.description   = %q{Add http/template helpers. and matcher for http response and json}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
