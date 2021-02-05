# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'luffa/version'

ruby_files = Dir.glob('{lib,bin}/**/*.rb')
doc_files =  ['README.md', 'LICENSE', 'CONTRIBUTING.md', 'VERSIONING.md']
plists = Dir.glob('script/ci/*.plist')
scripts = ['script/ci/.gemrc']

gem_files = ruby_files + doc_files + plists + scripts

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

  spec.required_ruby_version = ">= 2.0"
  spec.version       = Luffa::VERSION
  spec.platform      = Gem::Platform::RUBY

  spec.files         = gem_files
  spec.executables   = 'luffa'
  spec.require_paths = ['lib']

  spec.add_dependency 'awesome_print'
  spec.add_dependency 'json', '2.5.1'
  spec.add_dependency 'retriable', '< 2.1', '>= 1.3.3.1'
  spec.add_dependency 'thor', '~> 0.19'

  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'redcarpet', '~> 3.1'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'travis'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rake', '~> 13.0.3'
  spec.add_development_dependency 'guard-rspec', '~> 4.3'
  spec.add_development_dependency 'guard-bundler', '~> 2.0'
  spec.add_development_dependency 'growl', '~> 1.0'
  spec.add_development_dependency 'stub_env', '>= 1.0.1', '< 2.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-nav'

end
