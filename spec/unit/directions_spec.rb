require 'spec_helper'

ROME = '12.496365,41.902783'
BARI = '16.871871,41.117143'
SIDNEY = '151.206990,-33.867487'

# TODO: specs of validate_geo_coordinate and validate_location_params

RSpec.describe GoogleMapsJuice::Directions do
  let(:client) { GoogleMapsJuice::Client.new }
  let(:directions) { GoogleMapsJuice::Directions.new(client) }
  let(:endpoint) { '/directions/json' }

  describe '#directions' do
    subject { directions.directions(params) }

    context 'with bad params' do
      context 'when params is not a Hash' do
        let(:params) { 'foobar' }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(
            ArgumentError,
            'Hash argument expected'
          )
        end
      end

      context 'when some unsupported param is passed' do
        let(:params) { { origin:  BARI, foo: 'hey', bar: 'man' } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(
            ArgumentError,
            'The following params are not supported: foo, bar'
          )
        end
      end

      context 'when none of the required params is passed' do
        let(:params) { { region: 'US' } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(
            ArgumentError,
            'Any of the following params are required: address, components'
          )
        end
      end
    end

    context 'with good params' do
      before do
        expect(client).to receive(:get).with(endpoint, params).and_return(response)
      end

      context 'rome to bari geo-coordinates' do
        let(:response) { response_fixture('directions/rome_to_bari') }

        context 'with right geo-coordinates' do
          let(:params) { {
            origin: ROME,
            destination: BARI
          } }

          it 'returns one or more routes' do
            expect_rome_to_bari_result(subject)
          end
        end
      end

      context 'rome to sidney' do
        let(:response) { response_fixture('geocoding/rome_to_sidney') }

        context 'with right geo-cordinates' do
          let(:params) { {
            origin: ROME,
            destination: SIDNEY
          } }

          it 'returns no route result' do
            expect_rome_to_sidney_result(subject)
          end
        end
      end
    end
  end

  def expect_rome_to_bari_result(result)
    expect(result).to be_a GoogleMapsJuice::Directions::Response
    expect(result.routes.size).to be > 0
    expect(result.routes.first.summary).to eq '...'
    expect(result.routes.first.distance).to eq '...'
    expect(result.routes.first.duration).to eq '...'
    expect(result.routes.first.start_location).to eq '...'
    expect(result.routes.first.end_location).to eq '...'
    expect(result.routes.first.start_address).to eq '...'
    expect(result.routes.first.end_address).to eq '...'
    expect(result.routes.first.legs.size).to be > 0
    expect(result.routes.first.steps.size).to be > 0
  end

  def expect_rome_to_sidney_result(result)
    expect(result).to be_a GoogleMapsJuice::Directions::Response
    expect(result.routes.size).to eq 0
    expect(result.routes.first.summary).to be nil
    expect(result.routes.first.distance).to be nil
    expect(result.routes.first.duration).to be nil
    expect(result.routes.first.start_location).to be nil
    expect(result.routes.first.end_location).to be nil
    expect(result.routes.first.start_address).to be nil
    expect(result.routes.first.end_address).to be nil
    expect(result.routes.first.legs.size).to be nil
    expect(result.routes.first.steps.size).to be nil
  end
end
