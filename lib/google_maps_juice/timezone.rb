module GoogleMapsJuice
  class Timezone < Endpoint

    ENDPOINT = '/timezone'

    class << self
      def by_location(params, api_key: GoogleMapsJuice.config.api_key)
        client = GoogleMapsJuice::Client.new(api_key: api_key)
        self.new(client).by_location(params)
      end
    end

    def by_location(params)
      validate_params(params)
      response_text = @client.get("#{ENDPOINT}/json", build_request_params(params))
      response = JSON.parse(response_text, object_class: Response)
      detect_errors(response)
    end

    def validate_params(params)
      raise ArgumentError, 'Hash argument expected' unless params.is_a?(Hash)

      supported_keys = %w( latitude longitude timestamp language )
      validate_supported_params(params, supported_keys)

      required_keys = %w( latitude longitude )
      validate_all_required_params(params, required_keys)

      validate_timestamp_param(params)
      validate_location_params(params)
    end

    def validate_timestamp_param(params)
      if params.has_key?(:timestamp)
        raise ArgumentError, 'Timestamp must be a Time instance' unless params[:timestamp].is_a?(Time)
      end
    end

    def validate_location_params(params)
      if params[:latitude].abs > 90
        raise ArgumentError, 'Wrong latitude value'
      end
      if params[:longitude].abs > 180
        raise ArgumentError, 'Wrong longitude value'
      end
    end

    def build_request_params(params)
      seconds_since_epoch = (params[:timestamp] || Time.now).to_i
      {
        location: "#{params[:latitude]},#{params[:longitude]}",
        timestamp: seconds_since_epoch
      }.tap do |req_params|
        if params[:language]
          req_params[:language] = params[:language]
        end
      end
    end


    class Response < GoogleMapsJuice::Endpoint::Response

      def timezone_id
        self['timeZoneId']
      end

      def timezone_name
        self['timeZoneName']
      end

      def raw_offset
        self['rawOffset']
      end

      def dst_offset
        self['dstOffset']
      end

    end

  end
end
