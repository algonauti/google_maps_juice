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
      elsif response.error?
        msg = "API #{response.status}"
        msg += " - #{response.error_message}" if response.error_message.present?
        raise GoogleMapsJuice::Error, msg
      else
        response
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

      def error_message
        self['error_message']
      end

      def results
        self['results']
      end

    end

  end
end
