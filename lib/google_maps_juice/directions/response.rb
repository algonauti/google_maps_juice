# frozen_string_literal: true

require 'active_support/core_ext/hash/slice'

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
      attr_reader :route, :first_leg
      def initialize(route)
        @route = route
        @first_leg = route['legs'].first
      end

      def legs
        route['legs']
      end

      def summary
        route['summary']
      end

      def steps
        first_leg['steps']
      end

      def duration
        first_leg['duration']
      end

      def distance
        first_leg['distance']
      end

      def start_location
        first_leg['start_location'].to_s
      end

      def end_location
        first_leg['end_location'].to_s
      end

      def start_address
        first_leg['start_address']
      end

      def end_address
        first_leg['end_address']
      end
    end
  end
end
