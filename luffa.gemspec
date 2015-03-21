# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'luffa/version'

ruby_files = Dir.glob('{lib,bin}/**/*.rb')
doc_files =  ['README.md', 'LICENSE', 'CONTRIBUTING.md', 'VERSIONING.md']
gem_files = ruby_files + doc_files

Gem::Specification.new do |spec|
  spec.name          = 'luffa'
  spec.authors       = ['Jonas Maturana Larsen',
                        'Karl Krukow',
                        'Tobias Røikjer',
                        'Joshua Moody']
  spec.email         = ['jonaspec.larsen@xamarin.com',
                        'karl.krukow@xamarin.com',
                        'tobias.roikjer@xamarin.com',
                        'joshua.moody@xamarin.com']

  spec.summary       = 'A gem for testing the Calabash Toolchain'
  spec.description   =
        %q{Tools for testing the Calabash Toolchain locally, on Travis CI, and Jenkins}

  spec.homepage      = 'https://xamarin.com/test-cloud'
  spec.license       = 'EPL-1.0'

  spec.required_ruby_version = '>= 1.9'
  spec.version       = Luffa::VERSION
  spec.platform      = Gem::Platform::RUBY

  spec.files         = gem_files
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'awesome_print', '~> 1.2'
  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'retriable', '< 2.0', '>= 1.3.3.1'

  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'redcarpet', '~> 3.1'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'travis', '~> 1.7'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'guard-rspec', '~> 4.3'
  spec.add_development_dependency 'guard-bundler', '~> 2.0'
  spec.add_development_dependency 'growl', '~> 1.0'
  spec.add_development_dependency 'rb-readline', '~> 0.5'
  spec.add_development_dependency 'stub_env', '>= 1.0.1', '< 2.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-nav'

end

