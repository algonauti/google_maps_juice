module GoogleMapsJuice
  class Endpoint

    def initialize(client)
      @client = client
    end

    protected

    def detect_errors(response)
      raise ArgumentError, 'GoogleMapsJuice::Endpoint::Response argument expected' unless response.is_a?(Response)
      if response.zero_results?
        raise GoogleMapsJuice::ZeroResults
      elsif response.limit_error?
        raise GoogleMapsJuice::ApiLimitError, build_error_message(response)
      elsif response.error?
        raise GoogleMapsJuice::Error, "API #{build_error_message(response)}"
      else
        response
      end
    end

    def build_error_message(response)
      msg = response.status
      msg += " - #{response.error_message}" if response.error_message.present?
    end

    def validate_supported_params(params, supported_keys)
      unsupported_params = params.keys.select do |key|
        !supported_keys.include?(key.to_s)
      end
      if unsupported_params.present?
        raise ArgumentError, "The following params are not supported: #{unsupported_params.join(', ')}"
      end
    end

    def validate_required_params(params, required_keys, check_mode)
      required_params_present = required_keys.send("#{check_mode}?") do |key|
        params.keys.map(&:to_s).include?(key)
      end
      unless required_params_present
        verb = check_mode == 'one' ? 'is' : 'are'
        raise ArgumentError, "#{check_mode.capitalize} of the following params #{verb} required: #{required_keys.join(', ')}"
      end
    end


    %w( any one all ).each do |check_mode|

      define_method "validate_#{check_mode}_required_params" do |params, required_keys|
        validate_required_params(params, required_keys, check_mode)
      end

    end


    class Response < Hash

      def status
        self['status']
      end

      def error?
        status.upcase != 'OK'
      end

      def zero_results?
        status.upcase == 'ZERO_RESULTS'
      end

      def limit_error?
        %w( OVER_DAILY_LIMIT OVER_QUERY_LIMIT ).include?(status.upcase)
      end

      def error_message
        self['error_message']
      end

      def results
        self['results']
      end

    end

  end
end
