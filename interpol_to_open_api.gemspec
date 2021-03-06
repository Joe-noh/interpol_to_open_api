# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'interpol_to_open_api/version'

Gem::Specification.new do |spec|
  spec.name = "interpol_to_open_api"
  spec.version = InterpolToOpenAPI::VERSION
  spec.authors = ["Joe-noh"]
  spec.email = ["goflb.jh@gmail.com"]

  spec.summary = "Converts interpol endpoint definition into Open API spec."
  spec.homepage = "https://github.com/Joe-noh/interpol_to_open_api"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
