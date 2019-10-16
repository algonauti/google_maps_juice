module GoogleMapsJuice
  class Directions < Endpoint

    ENDPOINT = '/directions'

    autoload :Response, 'google_maps_juice/directions/response'

    class << self
      def find(params, api_key: GoogleMapsJuice.config.api_key)
        client = GoogleMapsJuice::Client.new(api_key: api_key)
        new(client).find(params)
      end
    end

    def find(params)
      validate_find_params(params)
      response_text = @client.get("#{ENDPOINT}/json", params)
      response = JSON.parse(response_text, object_class: Response)
      detect_errors(response)
    end

    def validate_find_params(params)
      raise ArgumentError, 'Hash argument expected' unless params.is_a?(Hash)

      supported_keys = %w[origin destination]
      validate_supported_params(params, supported_keys)

      required_keys = %w[origin destination]
      validate_any_required_params(params, required_keys)

      validate_geo_coordinate(params)
    end

    def validate_geo_coordinate(params)
      raise ArgumentError, 'String argument expected' unless params.values.all?(String)

      geocoords = params.values.map { |x| x.split(',') }.flatten
      geocoords.map! { |x| Float(x).round(7) }
      raise ArgumentError, 'Wrong geo-coordinates' if geocoords.size != 4

      validate_location_params(geocoords)
    end

    def validate_location_params(params)
      if params[0].abs > 90 || params[2].abs > 90
        raise ArgumentError, 'Wrong latitude value'
      end
      if params[1].abs > 180 || params[3].abs > 180
        raise ArgumentError, 'Wrong longitude value'
      end
    end
  end
end
