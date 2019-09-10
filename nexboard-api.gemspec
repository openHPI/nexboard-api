# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'nexboard-api'
  spec.version       = '0.3'
  spec.authors       = ['Xikolo Development Team']
  spec.email         = %w[xikolo-dev@hpi.uni-potsdam.de]
  spec.description   = 'Ruby wrapper for Nexboard API (https://nexboard.nexenio.com)'
  spec.summary       = 'Ruby wrapper for Nexboard API (https://nexboard.nexenio.com)'
  spec.homepage      = 'https://github.com/openHPI/nexboard-api'
  spec.license       = ''

  spec.files         = Dir['**/*'].grep(%r{((bin|lib|test|spec|features)/|
    .*\.gemspec|.*LICENSE.*|.*README.*|.*CHANGELOG.*)}x)
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib]

  spec.add_dependency 'restify'

  spec.add_development_dependency 'bundler', '~> 1.3'
end
