# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metabamf/version'

Gem::Specification.new do |spec|
  spec.name          = "metabamf"
  spec.version       = Metabamf::VERSION
  spec.authors       = ["Matt Patterson"]
  spec.email         = ["matt@reprocessed.org"]

  spec.summary       = %q{Basic ISOBMFF / MP4 file metadata parser}
  spec.homepage      = "https://www.github.com/fidothe/metabamf"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
