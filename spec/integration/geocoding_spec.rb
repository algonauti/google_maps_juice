require 'spec_helper'

RSpec.describe GoogleMapsJuice::Geocoding do

  describe '.geocode' do
    subject { described_class.geocode(params) }

    context 'full match on address', vcr: { cassette_name: 'geocoding/geocode/address-full-match' } do
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

    context 'full match on components', vcr: { cassette_name: 'geocoding/geocode/components-full-match' } do
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

    context 'full match on both address and components', vcr: { cassette_name: 'geocoding/geocode/address-and-components-full-match' } do
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

    context 'partial match on address', vcr: { cassette_name: 'geocoding/geocode/address-partial-match' } do
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

    context 'partial match on components (locality)', vcr: { cassette_name: 'geocoding/geocode/components-partial-match' } do
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

    context 'partial match on both address and components', vcr: { cassette_name: 'geocoding/geocode/address-and-components-partial-match' } do
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

    context 'no match on address', vcr: { cassette_name: 'geocoding/geocode/address-no-match' } do
      let(:params) { { address: 'impossible to geocode this!' } }

      it 'raises GoogleMapsJuice::ZeroResults' do
        expect { subject }.to raise_error(GoogleMapsJuice::ZeroResults)
      end
    end

    context 'no match on components (postal_code)', vcr: { cassette_name: 'geocoding/geocode/components-no-match' } do
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
  end

end
