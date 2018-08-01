module GoogleMapsJuice
  class Client
    attr_reader :api_key, :connection

    class << self
      def get(endpoint, params, api_key: GoogleMapsJuice.config.api_key)
        self.new(api_key: api_key).get(endpoint, params)
      end
    end

    API_HOST = 'https://maps.googleapis.com'
    API_PATH = '/maps/api'

    def initialize(api_key: GoogleMapsJuice.config.api_key)
      @api_key = api_key
      @connection = Excon.new(API_HOST)
    end

    def get(endpoint, params)
      full_params = (params || Hash.new).merge({ api_key: api_key })
      response = connection.get(
        path: "#{API_PATH}#{endpoint}",
        query: full_params
      )
      if healthy_http_status?(response.status)
        response.body
      else
        msg = "HTTP #{response.status}"
        msg += " - #{response.body}" if response.body.present?
        raise GoogleMapsJuice::Error, msg
      end
    end

    def healthy_http_status?(status)
      /^[123]\d{2}$/.match?("#{status}")
    end

  end
end
