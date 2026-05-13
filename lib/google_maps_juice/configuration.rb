module GoogleMapsJuice
  class Configuration
    attr_accessor :api_key

    def initialize
      @api_key = nil
    end
  end

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end
  end
end
