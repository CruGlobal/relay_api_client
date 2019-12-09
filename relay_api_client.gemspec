# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relay_api_client/version'

Gem::Specification.new do |spec|
  spec.name          = "relay_api_client"
  spec.version       = RelayApiClient::VERSION
  spec.authors       = ["Josh Starcher"]
  spec.email         = ["josh.starcher@gmail.com"]
  spec.description   = %q{Client for the Relay API}
  spec.summary       = %q{Client for the Relay API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'savon', '~> 2.1.0'
  spec.add_dependency 'global_registry', '~> 1.5'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
