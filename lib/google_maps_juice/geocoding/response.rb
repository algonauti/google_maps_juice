require 'active_support/core_ext/hash/slice'

module GoogleMapsJuice
  class Response < GoogleMapsJuice::Endpoint::Response

    def latitude
      location['lat']
    end

    def longitude
      location['lng']
    end

    def location
      result.dig('geometry', 'location')
    end

    def partial_match?
      result['partial_match'] == true
    end

    def result
      results.first
    end

    def address_components
      result['address_components']
    end

    def precision
      address_components&.first['types']&.first
    end


    %w( street_number
        route
        locality
        postal_code
        administrative_area_level_1
        administrative_area_level_2
        administrative_area_level_3
        country ).each do |type|

      define_method(type) do
        addr_component_by(type: type)&.slice('long_name', 'short_name')
      end

    end


    private

    def addr_component_by(type: '')
      address_components.find { |ac| ac['types'].include?(type) }
    end

  end
end
