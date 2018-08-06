require 'active_support/core_ext/object'
require 'active_support/dependencies/autoload'

require 'excon'
require 'json'

require 'google_maps_juice/configuration'
require 'google_maps_juice/version'

module GoogleMapsJuice
  extend ActiveSupport::Autoload

  autoload :Client, 'google_maps_juice/client'
  autoload :Endpoint, 'google_maps_juice/endpoint'
  autoload :Geocoding, 'google_maps_juice/geocoding'

  class Error < Exception; end
  class ApiLimitError < Exception; end
  class ZeroResults < Exception; end
end
