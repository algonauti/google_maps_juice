module GoogleMapsJuice
  class Client
    attr_reader :api_key, :connection

    class << self
      def get(endpoint, params)
        self.new.get(endpoint, params)
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
      connection.get(
        path: "#{API_PATH}#{endpoint}",
        query: full_params
      )
    end

  end
end
