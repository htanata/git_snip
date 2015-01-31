# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_snip/version'

Gem::Specification.new do |spec|
  spec.name          = "git_snip"
  spec.version       = GitSnip::VERSION
  spec.authors       = ["Hendy Tanata"]
  spec.email         = ["htanata@gmail.com"]
  spec.summary       = %q{Clean obsolete branches on your local git repository safely}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0") - %w(Guardfile)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "guard", "~> 2.11.1"
  spec.add_development_dependency "guard-rspec", "~> 4.5.0"
  spec.add_development_dependency "byebug", "~> 3.5.1"
end
