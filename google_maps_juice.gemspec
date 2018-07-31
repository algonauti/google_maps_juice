
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
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

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
end
