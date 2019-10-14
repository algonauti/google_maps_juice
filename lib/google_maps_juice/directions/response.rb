require 'active_support/core_ext/hash/slice'

# TODO: improve handling of legs and steps

module GoogleMapsJuice
  class Directions::Response < GoogleMapsJuice::Endpoint::Response
    def results
      self['routes']
    end

    def routes
      results.map { |r| Route.new(r) }
    end

    def first
      routes.first
    end

    class Route
      attr_reader :route
      def initialize(route)
        @route = route
      end
=begin
      def initialize(params)
        @summary = route['summary']
        @legs = route['legs']
        @step = route['legs']['steps']
        @duration = route['duration']
        @distance = route['distance']
        @start_location = route['start_location']
        @end_location = route['end_location']
        @start_address = route['start_address']
        @end_address = route['end_address']
      end
=end

      def summary
        route[:summary]
      end

      def legs
        route[:legs]
      end

      def steps
        route.dig[:legs, :steps]
      end

      def duration
        route[:duration]
      end

      def distance
        route[:distance]
      end

      def start_location
        route[:start_location].to_s
      end

      def end_location
        route[:end_location].to_s
      end

      def start_address
        route[:start_address]
      end

      def end_address
        route[:end_address]
      end
    end
  end
end
