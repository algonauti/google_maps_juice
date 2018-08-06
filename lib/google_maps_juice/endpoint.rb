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
