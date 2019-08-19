# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
#noinspection RubyResolve
require 'everyday-plugins/version'

Gem::Specification.new do |spec|
  spec.name          = 'everyday-plugins'
  spec.version       = EverydayPlugins::VERSION
  spec.authors       = ['Eric Henderson']
  spec.email         = ['henderea@gmail.com']
  spec.summary       = %q{A simple gem plugin system}
  spec.description   = %q{A simple gem plugin system.  Extracted from the mvn2 gem.}
  spec.homepage      = 'https://github.com/henderea/everyday-plugins'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.8'

  spec.add_dependency 'everyday-cli-utils', '~> 1.8', '>= 1.8.7.2'
end
