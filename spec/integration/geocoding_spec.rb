require 'spec_helper'

RSpec.describe GoogleMapsJuice::Geocoding do

  describe '.geocode' do
    subject { described_class.geocode(params) }

    context 'full match on address', vcr: {
      cassette_name: 'geocoding/geocode/address-full-match'
    } do
      let(:params) { { address: 'via Fragata 35, 76011 Bisceglie BT Italia', language: 'it' } }

      it 'returns fully-maching result with street_number precision' do
        expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
        expect(subject.partial_match?).to be false
        expect(subject.latitude).to eq 41.2403256
        expect(subject.longitude).to eq 16.507746
        expect(subject.precision).to eq 'street_number'
        expect(subject.street_number['short_name']).to eq '35'
        expect(subject.route['short_name']).to eq 'Via Fragata'
        expect(subject.locality['short_name']).to eq 'Bisceglie'
        expect(subject.postal_code['short_name']).to eq '76011'
        expect(subject.administrative_area_level_1['long_name']).to eq 'Puglia'
        expect(subject.country['long_name']).to eq 'Italia'
      end
    end

    context 'full match on components', vcr: {
      cassette_name: 'geocoding/geocode/components-full-match'
    } do
      let(:params) { { components: 'locality:Miami|postal_code:33137|administrative_area:FL|country:US' } }

      it 'returns fully-maching result with postal_code precision' do
        expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
        expect(subject.partial_match?).to be false
        expect(subject.latitude).to eq 25.8207159
        expect(subject.longitude).to eq -80.1819268
        expect(subject.precision).to eq 'postal_code'
        expect(subject.street_number).to be nil
        expect(subject.route).to be nil
        expect(subject.locality['short_name']).to eq 'Miami'
        expect(subject.postal_code['short_name']).to eq '33137'
        expect(subject.administrative_area_level_1['long_name']).to eq 'Florida'
        expect(subject.country['long_name']).to eq 'United States'
      end
    end

    context 'full match on both address and components', vcr: {
      cassette_name: 'geocoding/geocode/address-and-components-full-match'
    } do
      let(:params) do
        {
          address: '209 Annie Street',
          components: 'locality:Orlando|postal_code:32806|administrative_area:FL|country:US'
        }
      end

      it 'returns fully-maching result with street_number precision' do
        expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
        expect(subject.partial_match?).to be false
        expect(subject.latitude).to eq 28.5294462
        expect(subject.longitude).to eq -81.37502689999999
        expect(subject.precision).to eq 'street_number'
        expect(subject.street_number['short_name']).to eq '209'
        expect(subject.route['long_name']).to eq 'Annie Street'
        expect(subject.locality['short_name']).to eq 'Orlando'
        expect(subject.postal_code['short_name']).to eq '32806'
        expect(subject.administrative_area_level_1['long_name']).to eq 'Florida'
        expect(subject.country['long_name']).to eq 'United States'
      end
    end

    context 'partial match on address', vcr: {
      cassette_name: 'geocoding/geocode/address-partial-match'
    } do
      let(:params) { { address: '209 Angie St, Orlando, FL 32806, USA' } }

      it 'returns partially-maching result with postal_code precision' do
        expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
        expect(subject.partial_match?).to be true
        expect(subject.latitude).to eq 28.5085825
        expect(subject.longitude).to eq -81.3564411
        expect(subject.precision).to eq 'postal_code'
        expect(subject.street_number).to be nil
        expect(subject.route).to be nil
        expect(subject.locality['short_name']).to eq 'Orlando'
        expect(subject.postal_code['short_name']).to eq '32806'
        expect(subject.administrative_area_level_1['long_name']).to eq 'Florida'
        expect(subject.country['long_name']).to eq 'United States'
      end
    end

    context 'partial match on components (locality)', vcr: {
      cassette_name: 'geocoding/geocode/components-partial-match'
    } do
      let(:params) { { components: 'locality:Macao|postal_code:33137|administrative_area:FL|country:US' } }

      it 'returns partially-maching result with postal_code precision' do
        expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
        expect(subject.partial_match?).to be true
        expect(subject.latitude).to eq 25.8207159
        expect(subject.longitude).to eq -80.1819268
        expect(subject.precision).to eq 'postal_code'
        expect(subject.street_number).to be nil
        expect(subject.route).to be nil
        expect(subject.locality['short_name']).to eq 'Miami'
        expect(subject.postal_code['short_name']).to eq '33137'
        expect(subject.administrative_area_level_1['long_name']).to eq 'Florida'
        expect(subject.country['long_name']).to eq 'United States'
      end
    end

    context 'partial match on both address and components', vcr: {
      cassette_name: 'geocoding/geocode/address-and-components-partial-match'
    } do
      let(:params) do
        {
          address: '209 Angie Street',
          components: 'locality:Ronaldo|postal_code:32806|administrative_area:FL|country:US'
        }
      end

      it 'returns partially-maching result with postal_code precision' do
        expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
        expect(subject.partial_match?).to be true
        expect(subject.latitude).to eq 28.5085825
        expect(subject.longitude).to eq -81.3564411
        expect(subject.precision).to eq 'postal_code'
        expect(subject.street_number).to be nil
        expect(subject.route).to be nil
        expect(subject.locality['short_name']).to eq 'Orlando'
        expect(subject.postal_code['short_name']).to eq '32806'
        expect(subject.administrative_area_level_1['long_name']).to eq 'Florida'
        expect(subject.country['long_name']).to eq 'United States'
      end
    end

    context 'no match on address', vcr: {
      cassette_name: 'geocoding/geocode/address-no-match'
    } do
      let(:params) { { address: 'impossible to geocode this!' } }

      it 'raises GoogleMapsJuice::ZeroResults' do
        expect { subject }.to raise_error(GoogleMapsJuice::ZeroResults)
      end
    end

    context 'no match on components (postal_code)', vcr: {
      cassette_name: 'geocoding/geocode/components-no-match'
    } do
      let(:params) do
        {
          address: '1900 Gorgas St',
          components: 'locality:Montgomery|postal_code:36ABC|administrative_area:AL|country:US'
        }
      end

      it 'raises GoogleMapsJuice::ZeroResults' do
        expect { subject }.to raise_error(GoogleMapsJuice::ZeroResults)
      end
    end
  end


  describe '.i_geocode' do
    subject { described_class.i_geocode(params) }

    context 'when postal_code is wrong, but address is correct', vcr: {
      cassette_name: 'geocoding/i_geocode/address-wrong'
    } do
      let(:params) do
        {
          address: '1900 Gorgas St',
          locality: 'Montgomery',
          postal_code: '36ABC',
          administrative_area: 'AL',
          country: 'US'
        }
      end

      it 'geocodes address correctly' do
        expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
        expect(subject.partial_match?).to be false
        expect(subject.latitude).to eq 32.359547
        expect(subject.longitude).to eq -86.2762671
        expect(subject.precision).to eq 'street_number'
        expect(subject.street_number['short_name']).to eq '1900'
        expect(subject.route['long_name']).to eq 'Gorgas Street'
        expect(subject.locality['short_name']).to eq 'Montgomery'
        expect(subject.postal_code['short_name']).to eq '36106'
        expect(subject.administrative_area_level_1['long_name']).to eq 'Alabama'
        expect(subject.country['long_name']).to eq 'United States'
      end
    end

    context 'when both postal_code and address are wrong', vcr: {
      cassette_name: 'geocoding/i_geocode/address-and-postal_code-wrong'
    } do
      let(:params) do
        {
          address: 'Nowhere to go',
          locality: 'Montgomery',
          postal_code: '36ABC',
          administrative_area: 'AL',
          country: 'US'
        }
      end

      it 'geocodes locality' do
        expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
        expect(subject.partial_match?).to be false
        expect(subject.latitude).to eq 32.3792233
        expect(subject.longitude).to eq -86.3077368
        expect(subject.precision).to eq 'locality'
        expect(subject.street_number).to be nil
        expect(subject.route).to be nil
        expect(subject.postal_code).to be nil
        expect(subject.locality['short_name']).to eq 'Montgomery'
        expect(subject.administrative_area_level_1['long_name']).to eq 'Alabama'
        expect(subject.country['long_name']).to eq 'United States'
      end
    end

    context 'when postal_code, address and locality are wrong', vcr: {
      cassette_name: 'geocoding/i_geocode/address-postal_code-and-locality-wrong'
    } do
      let(:params) do
        {
          address: 'Nowhere to go',
          locality: 'Monkmily',
          postal_code: '36ABC',
          administrative_area: 'AL',
          country: 'US'
        }
      end

      it 'geocodes administrative_area' do
        expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
        expect(subject.partial_match?).to be false
        expect(subject.latitude).to eq 32.3182314
        expect(subject.longitude).to eq -86.902298
        expect(subject.precision).to eq 'administrative_area_level_1'
        expect(subject.street_number).to be nil
        expect(subject.route).to be nil
        expect(subject.postal_code).to be nil
        expect(subject.locality).to be nil
        expect(subject.administrative_area_level_1['long_name']).to eq 'Alabama'
        expect(subject.country['long_name']).to eq 'United States'
      end
    end

    context 'when all params except country are wrong', vcr: {
        cassette_name: 'geocoding/i_geocode/all-except-country-wrong'
      } do
        let(:params) do
          {
            address: 'Impossible to geocode',
            locality: 'Monkmily',
            postal_code: '36ABC',
            administrative_area: 'Macao',
            country: 'US'
          }
        end

      it 'geocodes country' do
        expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
        expect(subject.precision).to eq 'country'
        expect(subject.street_number).to be nil
        expect(subject.route).to be nil
        expect(subject.postal_code).to be nil
        expect(subject.locality).to be nil
        expect(subject.administrative_area_level_1).to be nil
        expect(subject.country['long_name']).to eq 'United States'
      end
    end

  end
end
