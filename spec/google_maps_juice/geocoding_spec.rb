require 'spec_helper'

RSpec.describe GoogleMapsJuice::Geocoding do
  let(:client) { GoogleMapsJuice::Client.new }
  let(:geocoding) { GoogleMapsJuice::Geocoding.new(client) }
  let(:base_url) { 'https://maps.googleapis.com/maps/api' }
  let(:endpoint) { '/geocode/json' }
  let(:url_pattern) { Regexp.new("#{base_url}#{endpoint}*") }
  let(:query_string) do
    params.merge({ api_key: GoogleMapsJuice.config.api_key }).to_query
  end

  describe '#geocode' do

    subject { geocoding.geocode(params) }


    context 'with bad params' do

      context 'when params is not a Hash' do
        let(:params) { 'foobar' }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError, 'Hash argument expected')
        end
      end

      context 'when some unsupported param is passed' do
        let(:params) { { address: '123 Pine Road', foo: 'hey', bar: 'man' } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError,
            'The following params are not supported: foo, bar')
        end
      end

      context 'when none of the required params is passed' do
        let(:params) { { region: 'US' } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError,
            'One of the following params is required: address, components')
        end
      end
    end


    context 'with good params' do

      before do
        expect(client).to receive(:get).with(endpoint, params).and_return(response)
      end


      context 'full match' do
        let(:response) { response_fixture('geocoding/lantana-rd') }

        context 'with a full address' do
          let(:params) { { address: '8955 Lantana Rd, Crossville, TN 38572, USA' } }

          it 'returns fully-maching result' do
            expect_lantana_rd_result(subject)
          end
        end

        context 'with address, components, and language' do
          let(:params) do
            {
              address: '8955 Lantana Rd',
              components: 'locality:Crossville|postal_code:38572|administrative_area:TN|country:US',
              language: 'en'
            }
          end

          it 'returns fully-maching result' do
            expect_lantana_rd_result(subject)
          end
        end

        def expect_lantana_rd_result(result)
          expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
          expect(subject.partial_match?).to be false
          expect(subject.latitude).to eq 35.8458658
          expect(subject.longitude).to eq -85.1265277
          expect(subject.street_number['short_name']).to eq '8955'
          expect(subject.route['short_name']).to eq 'Lantana Rd'
          expect(subject.locality['short_name']).to eq 'Crossville'
          expect(subject.postal_code['short_name']).to eq '38572'
          expect(subject.administrative_area_level_1['long_name']).to eq 'Tennessee'
          expect(subject.country['long_name']).to eq 'United States'
        end

      end


      context 'partial match' do
        let(:response) { response_fixture('geocoding/crossville') }

        context 'with wrong street in a full address' do
          let(:params) { { address: '89A Foobar Road, Crossville, TN 38572, USA' } }

          it 'returns partially-maching result' do
            expect_crossville_result(subject)
          end
        end

        context 'with no postal code and wrong locality in components param' do
          let(:params) do
            { components: 'locality:Croxvil|administrative_area:TN|country:US' }
          end

          it 'returns partially-maching result with similarly-named locality' do
            expect_crossville_result(subject)
          end
        end

        def expect_crossville_result(result)
          expect(subject).to be_a GoogleMapsJuice::Geocoding::Response
          expect(subject.partial_match?).to be true
          expect(subject.latitude).to eq 35.9489566
          expect(subject.longitude).to eq -85.0269014
          expect(subject.street_number).to be nil
          expect(subject.route).to be nil
          expect(subject.locality['short_name']).to eq 'Crossville'
          expect(subject.postal_code).to be nil
          expect(subject.administrative_area_level_1['long_name']).to eq 'Tennessee'
          expect(subject.country['long_name']).to eq 'United States'
        end

      end

    end
  end

end
