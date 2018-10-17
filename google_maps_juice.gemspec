
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "google_maps_juice/version"

Gem::Specification.new do |spec|
  spec.name          = "google_maps_juice"
  spec.version       = GoogleMapsJuice::VERSION
  spec.authors       = ["Davide Papagni"]
  spec.email         = ["davide@algonauti.com"]

  spec.summary       = "Client for popular Google Maps API Services: Geocoding, Time Zones"
  spec.description   = "Put Google Maps APIs in a spin-dryer and drink their juice: Geocoding, Time Zones, ...and more upcoming!"
  spec.homepage      = "https://github.com/algonauti/google_maps_juice"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '~> 5.2'
  spec.add_dependency 'excon'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'webmock', '~> 3.4'
  spec.add_development_dependency 'dotenv', '~> 2.5'
  spec.add_development_dependency 'vcr', '~> 4.0'
  spec.add_development_dependency 'coveralls', '~> 0.8'
end
