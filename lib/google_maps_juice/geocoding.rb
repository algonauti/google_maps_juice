require 'google_maps_juice/geocoding/response'

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

  end
end
