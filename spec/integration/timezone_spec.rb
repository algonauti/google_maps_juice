require 'spec_helper'

RSpec.describe GoogleMapsJuice::Timezone do

  describe '.by_location' do
    subject { described_class.by_location(params) }

    context 'result found', vcr: {
      cassette_name: 'timezone/success'
    } do
      let(:params) { { latitude: -89.9, longitude: -179.9, timestamp: Time.parse("2018-09-04T22:00:00Z") } }

      it 'returns response object' do
        expect(subject).to be_a GoogleMapsJuice::Timezone::Response
      end
    end

    context 'result not found', vcr: {
      cassette_name: 'timezone/zero_results'
    } do
      let(:params) { { latitude: 90, longitude: 180, timestamp: Time.parse("2018-09-04T22:00:00Z") } }

      it 'raises GoogleMapsJuice::ZeroResults' do
        expect { subject }.to raise_error(GoogleMapsJuice::ZeroResults)
      end
    end

  end

end
