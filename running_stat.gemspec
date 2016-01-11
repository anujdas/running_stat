# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'running_stat/version'

Gem::Specification.new do |spec|
  spec.name          = 'running_stat'
  spec.version       = RunningStat::VERSION
  spec.authors       = ['Anuj Das']
  spec.email         = ['anujdas@gmail.com']

  spec.summary       = %q{A distributed streaming mean, variance, and standard deviation metric}
  spec.description   = %q{Using redis, allows statistics calculations on a streaming set of data without storing every value}
  spec.homepage      = 'https://www.github.com/anujdas/running_stat'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'redis', '~> 3.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
