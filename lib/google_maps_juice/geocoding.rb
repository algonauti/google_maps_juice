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
      validate_geocode_params(params)
      response_text = @client.get("#{ENDPOINT}/json", params)
      response = JSON.parse(response_text, object_class: Response)
      detect_errors(response)
    end

    def i_geocode(params)
      validate_i_geocode_params(params)
      req_params = build_req_params(params)
      # TODO
    end

    def validate_geocode_params(params)
      raise ArgumentError, 'Hash argument expected' unless params.is_a?(Hash)

      supported_keys = %w( address components bounds language region )
      validate_supported_params(params, supported_keys)

      required_keys = %w( address components )
      validate_required_params(params, required_keys)
    end

    def validate_i_geocode_params(params)
      raise ArgumentError, 'Hash argument expected' unless params.is_a?(Hash)

      supported_keys = %w( address locality postal_code administrative_area country language)
      validate_supported_params(params, supported_keys)

      required_keys = %w( address country )
      validate_required_params(params, required_keys)
    end

    def build_req_params(i_geocode_params)
      req_params = Hash.new

      [:address, :language].each do |key|
        if params[key].present?
          req_params[key] = params[key]
        end
      end

      components = build_components_param(params, keys:
        [:locality, :postal_code, :administrative_area, :country]
      )
      if components.present?
        req_params[:components] = components
      end

      req_params
    end

    def build_components_param(params, keys: [])
      keys.map do |key|
        if params[key].present?
          "#{key}:#{params[key]}"
        end
      end.compact.join('|')
    end

    def validate_supported_params(params, supported_keys)
      unsupported_params = params.keys.select do |key|
        !supported_keys.include?(key.to_s)
      end
      if unsupported_params.present?
        raise ArgumentError, "The following params are not supported: #{unsupported_params.join(', ')}"
      end
    end

    def validate_required_params(params, required_keys)
      required_params_present = params.keys.any? do |key|
        required_keys.include?(key.to_s)
      end
      unless required_params_present
        raise ArgumentError, "One of the following params is required: #{required_keys.join(', ')}"
      end
    end

  end
end
