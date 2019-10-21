# frozen_string_literal: true

require 'spec_helper'

ROME = '12.496365,41.902783'
COLOSSEUM = '41.890209,12.492231'
SAINTPETER = '41.902270,12.457540'
SIDNEY = '-33.867487,151.206990'

# TODO: cover the remaining contexts
RSpec.describe GoogleMapsJuice::Directions do
  let(:client) { GoogleMapsJuice::Client.new }
  let(:directions) { GoogleMapsJuice::Directions.new(client) }
  let(:endpoint) { '/directions/json' }

  describe '#directions' do
    subject { directions.find(params) }

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
        let(:params) { { origin:  ROME, foo: 'hey', bar: 'man' } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(
            ArgumentError,
            'The following params are not supported: foo, bar'
          )
        end
      end

      context 'when some of the required params is not passed' do
        let(:params) { { region: 'US' } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(
            ArgumentError,
            'The following params are not supported: region'
          )
        end
      end

      context 'when wrong geo-coordinate is passed' do
        let(:params) { { origin: '0.0000000,0.0000000' } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(
            ArgumentError,
            'Wrong geo-coordinates'
          )
        end
      end

      context 'when no argument passed' do
        let(:params) { {} }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(
            ArgumentError,
            'Any of the following params are required: origin, destination'
          )
        end
      end

    end

    context 'with good params' do
      before do
        expect(client).to receive(:get).with(endpoint, params).and_return(response)
      end

      context 'Rome, from Colosseum to Saint Peter' do
        let(:response) { response_fixture('directions/colosseum-s_peter') }

        context 'with right geo-coordinates' do
          let(:params) do
            {
              origin: COLOSSEUM,
              destination: SAINTPETER
            }
          end

          it 'returns one or more routes' do
            expect_colosseum_to_s_peter_result(subject)
          end
        end
      end

      context 'Rome, from Colosseum to Colosseum' do
        let(:response) { response_fixture('directions/colosseum-colosseum') }

        context 'with same geo-coordinates' do
          let(:params) do
            {
              origin: COLOSSEUM,
              destination: COLOSSEUM
            }
          end

          it 'returns single route composed of one leg with one step of 1m and 1min' do
            expect_colosseum_to_colosseum_result(subject)
          end
        end
      end

      context 'from Rome to Sidney' do
        let(:response) { response_fixture('directions/rome-sydney') }

        context 'with right geo-cordinates' do
          let(:params) do
            {
              origin: ROME,
              destination: SIDNEY
            }
          end

          it 'raises ZeroResults' do
            expect { subject }.to raise_error(GoogleMapsJuice::ZeroResults)
          end
        end
      end
    end
  end

  def expect_colosseum_to_s_peter_result(result)
    expect(result).to be_a GoogleMapsJuice::Directions::Response
    expect(result.routes).to be_a Array
    expect(result.routes.size).to be > 0
    first_route = result.first
    expect(first_route).to be_a GoogleMapsJuice::Directions::Response::Route
    expect(first_route.summary).to eq 'Via dei Cerchi'
    expect(first_route.legs).to be_a Array
    expect(first_route.legs.size).to be >= 1
    expect(first_route.duration['text']).to eq '13 mins'
    expect(first_route.distance['text']).to eq '4.5 km'
    expect(first_route.steps).to be_a Array
    expect(first_route.steps.size).to be >= 1
    expect(first_route.start_location['lat']).to eq 41.8892732
    expect(first_route.start_location['lng']).to eq 12.4921921
    expect(first_route.end_location['lat']).to eq 41.9016488
    expect(first_route.end_location['lng']).to eq 12.4583003
    expect(first_route.start_address).to eq 'Piazza del Colosseo, 1, 00184 Roma RM, Italy'
    expect(first_route.end_address).to eq 'Piazza Pio Xii, 1, 00193 Roma RM, Italy'
  end

  def expect_colosseum_to_colosseum_result(result)
    expect(result).to be_a GoogleMapsJuice::Directions::Response
    expect(result.routes).to be_a Array
    expect(result.routes.size).to be 1
    first_route = result.first
    expect(first_route).to be_a GoogleMapsJuice::Directions::Response::Route
    expect(first_route.summary).to eq 'Via Celio Vibenna'
    expect(first_route.legs).to be_a Array
    expect(first_route.legs.size).to be >= 1
    expect(first_route.duration['text']).to eq '1 min'
    expect(first_route.distance['text']).to eq '1 m'
    expect(first_route.steps).to be_a Array
    expect(first_route.steps.size).to be >= 1
    expect(first_route.start_location['lat']).to eq 41.8892732
    expect(first_route.start_location['lng']).to eq 12.4921921
    expect(first_route.end_location['lat']).to eq 41.8892732
    expect(first_route.end_location['lng']).to eq 12.4921921
    expect(first_route.start_address).to eq 'Piazza del Colosseo, 1, 00184 Roma RM, Italy'
    expect(first_route.end_address).to eq 'Piazza del Colosseo, 1, 00184 Roma RM, Italy'
  end

  def expect_rome_to_sidney_result(result)
    expect(result).to be_a GoogleMapsJuice::Directions::Response
    expect(result['status']).to eq 'ZERO_RESULTS'
    expect(result['routes']).to be Array
    expect(result['routes'].size).to be 0
  end
end
