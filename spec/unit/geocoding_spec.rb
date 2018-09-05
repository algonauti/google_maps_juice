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
            'Any of the following params are required: address, components')
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
          let(:params) { { address: '8955 Lantana Rd, Lake Worth, FL 33467, USA' } }

          it 'returns fully-maching result' do
            expect_lantana_rd_result(subject)
          end
        end

        context 'with address, components, and language' do
          let(:params) do
            {
              address: '8955 Lantana Rd',
              components: 'locality:Lake Worth|postal_code:33467|administrative_area:FL|country:US',
              language: 'en'
            }
          end

          it 'returns fully-maching result' do
            expect_lantana_rd_result(subject)
          end
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

      end

    end
  end


  describe '#i_geocode' do

    subject { geocoding.i_geocode(params) }


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
        let(:params) { { postal_code: 'AB345' } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError,
            'Any of the following params are required: address, country')
        end
      end
    end

    context 'with good params' do

      context 'with address param only' do
        let(:params) { { address: '8955 Lantana Rd, Lake Worth, FL 33467, USA' } }
        let(:response) { response_fixture('geocoding/lantana-rd') }
        let(:standard_geocode_result) { geocoding.geocode(params) }

        before do
          expect(client).to receive(:get).with(endpoint, params).and_return(response)
        end

        it 'behaves like the standard #geocode method' do
          expect(geocoding).to receive(:geocode).with(params).once.and_return(standard_geocode_result)
          expect_lantana_rd_result(subject)
        end
      end

      context 'when the first call to #geocode raises a ZeroResults exception' do
        before do
          expect(geocoding).to receive(:geocode).with(geocode_1st_call_params).once.and_raise(GoogleMapsJuice::ZeroResults)
        end

        context 'when both postal_code and address are present' do
          let(:params) { { postal_code: '12345', address: '10 Pine Street', country: 'US' } }
          let(:geocode_1st_call_params) { { address: '10 Pine Street', components: 'postal_code:12345|country:US' } }
          let(:geocode_2nd_call_params) { { address: '10 Pine Street', components: 'country:US' } }

          it 'removes postal_code and retries' do
            expect(geocoding).to receive(:geocode).with(geocode_2nd_call_params).once
            subject
          end

          context 'when removing postal_code still raises ZeroResults' do
            before do
              expect(geocoding).to receive(:geocode).with(geocode_2nd_call_params).once.and_raise(GoogleMapsJuice::ZeroResults)
            end

            let(:geocode_3rd_call_params) { { components: 'country:US' } }

            it 'removes address and retries' do
              expect(geocoding).to receive(:geocode).with(geocode_3rd_call_params).once
              subject
            end

            context 'and removing address still raises ZeroResults' do
              before do
                expect(geocoding).to receive(:geocode).with(geocode_3rd_call_params).once.and_raise(GoogleMapsJuice::ZeroResults)
              end

              it 'raises ZeroResults' do
                expect { subject }.to raise_error(GoogleMapsJuice::ZeroResults)
              end
            end

          end
        end

        context 'when postal_code is present and address is not present' do
          let(:params) { { postal_code: '12345', country: 'US' } }
          let(:geocode_1st_call_params) { { components: 'postal_code:12345|country:US' } }
          let(:geocode_2nd_call_params) { { components: 'country:US' } }

          it 'removes postal_code and retries' do
            expect(geocoding).to receive(:geocode).with(geocode_2nd_call_params).once
            subject
          end

          context 'when removing postal_code still raises ZeroResults' do
            before do
              expect(geocoding).to receive(:geocode).with(geocode_2nd_call_params).once.and_raise(GoogleMapsJuice::ZeroResults)
            end

            it 'raises ZeroResults' do
              expect { subject }.to raise_error(GoogleMapsJuice::ZeroResults)
            end
          end
        end

        context 'when postal_code is not present and address is present' do
          let(:params) { { address: '10 Pine Street', country: 'US' } }
          let(:geocode_1st_call_params) { { address: '10 Pine Street', components: 'country:US' } }
          let(:geocode_2nd_call_params) { { components: 'country:US' } }

          it 'removes address and retries' do
            expect(geocoding).to receive(:geocode).with(geocode_2nd_call_params).once
            subject
          end

          context 'and removing address still raises ZeroResults' do
            before do
              expect(geocoding).to receive(:geocode).with(geocode_2nd_call_params).once.and_raise(GoogleMapsJuice::ZeroResults)
            end

            it 'raises ZeroResults' do
              expect { subject }.to raise_error(GoogleMapsJuice::ZeroResults)
            end
          end
        end
      end
    end
  end

  def expect_lantana_rd_result(result)
    expect(result).to be_a GoogleMapsJuice::Geocoding::Response
    expect(result.partial_match?).to be false
    expect(result.latitude).to eq 26.5914658
    expect(result.longitude).to eq -80.18846549999999
    expect(result.precision).to eq 'street_number'
    expect(result.street_number['short_name']).to eq '8955'
    expect(result.route['short_name']).to eq 'Lantana Rd'
    expect(result.locality['short_name']).to eq 'Lake Worth'
    expect(result.postal_code['short_name']).to eq '33467'
    expect(result.administrative_area_level_1['long_name']).to eq 'Florida'
    expect(result.country['long_name']).to eq 'United States'
  end

  def expect_crossville_result(result)
    expect(result).to be_a GoogleMapsJuice::Geocoding::Response
    expect(result.partial_match?).to be true
    expect(result.latitude).to eq 35.9489566
    expect(result.longitude).to eq -85.0269014
    expect(result.precision).to eq 'locality'
    expect(result.street_number).to be nil
    expect(result.route).to be nil
    expect(result.locality['short_name']).to eq 'Crossville'
    expect(result.postal_code).to be nil
    expect(result.administrative_area_level_1['long_name']).to eq 'Tennessee'
    expect(result.country['long_name']).to eq 'United States'
  end

end
