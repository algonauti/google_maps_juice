require 'active_support/core_ext/hash/slice'

module GoogleMapsJuice
  class Directions::Response < GoogleMapsJuice::Endpoint::Response
    def location
      result.dig('geometry', 'location')
    end

    def partial_match?
      result['partial_match'] == true
    end

    def route
      routes.first
    end

    def summary
      route.first['summary']
    end

    def legs
      route['legs']
    end

    def steps
      legs['steps']
    end

    def duration
      route['duration']
    end

    def distance
      route['distance']
    end

    def start_location
      route['start_location']
    end

    def end_location
      route['end_location']
    end

    def start_address
      route['start_address']
    end

    def end_address
      route['end_address']
    end
  end
end
