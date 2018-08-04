require 'active_support/core_ext/hash/slice'

module GoogleMapsJuice
  class Geocoding < Endpoint

    ENDPOINT = '/geocode'

    class << self
      def geocode(params, api_key: GoogleMapsJuice.config.api_key)
        client = GoogleMapsJuice::Client.new(api_key: api_key)
        self.new(client).geocode(params)
      end
    end


    def geocode(params)
      validate_params(params)
      response_text = @client.get("#{ENDPOINT}/json", params)
      response = JSON.parse(response_text, object_class: Response)
      detect_errors(response)
    end

    def validate_params(params)
      raise ArgumentError, 'Hash argument expected' unless params.is_a?(Hash)

      supported_params = %w( address components bounds language region )
      unsupported_params = params.keys.select do |key|
        !supported_params.include?(key.to_s)
      end
      if unsupported_params.present?
        raise ArgumentError, "The following params are not supported: #{unsupported_params.join(', ')}"
      end

      required_params = %w( address components )
      required_params_present = params.keys.any? do |key|
        required_params.include?(key.to_s)
      end
      unless required_params_present
        raise ArgumentError, "One of the following params is required: #{required_params.join(', ')}"
      end
    end


    class Response < GoogleMapsJuice::Endpoint::Response

      def latitude
        location['lat']
      end

      def longitude
        location['lng']
      end

      def location
        result.dig('geometry', 'location')
      end

      def partial_match?
        result['partial_match'] == true
      end

      def result
        results.first
      end

      def address_components
        result['address_components']
      end


      %w( street_number
          route
          locality
          postal_code
          administrative_area_level_1
          administrative_area_level_2
          administrative_area_level_3
          country ).each do |type|

        define_method(type) do
          addr_component_by(type: type)&.slice('long_name', 'short_name')
        end

      end


      private

      def addr_component_by(type: '')
        address_components.find { |ac| ac['types'].include?(type) }
      end

    end

  end
end
