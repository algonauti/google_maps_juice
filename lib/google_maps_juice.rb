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
  autoload :Timezone, 'google_maps_juice/timezone'
  autoload :Directions, 'google_maps_juice/directions'

  class ResponseError < RuntimeError; end
  class ApiLimitError < ResponseError; end
  class ZeroResults < ResponseError; end
end
