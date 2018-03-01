
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rubyrave/version"

Gem::Specification.new do |spec|
  spec.name          = "rubyrave"
  spec.version       = Rubyrave::VERSION
  spec.authors       = ["Michael Bluman"]
  spec.email         = ["reasonsbluman@gmail.com"]

  spec.summary       = %q{This library is a wrapper of Rave API}
  spec.description   = %q{This is a ruby gem that priovides API access to Rave.}
  spec.homepage      = "https://github.com/bluman1/rubyrave/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_dependency "httparty", "~>0.16.0"
end
