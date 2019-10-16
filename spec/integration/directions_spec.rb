# frozen_string_literal: true

require 'spec_helper'

ROME = '12.496365,41.902783'
COLOSSEUM = '41.890209,12.492231'
SAINTPETER = '41.902270,12.457540'
SIDNEY = '-33.867487,151.206990'

RSpec.describe GoogleMapsJuice::Directions do
  describe '.directions' do
    subject { described_class.directions(params) }

    context 'full match on address', vcr: {
      cassette_name: 'directions/directions/valid-coordinates'
    } do
      let(:params) { { origin: COLOSSEUM, destination: SAINTPETER } }

      it 'returns valid route' do
        expect(subject).to be_a GoogleMapsJuice::Directions::Response
        expect(subject.routes).to be_a Array
        expect(subject.routes.size).to be > 0
        first_route = subject.first
        expect(first_route).to be_a GoogleMapsJuice::Directions::Response::Route
        expect(first_route.summary).to eq 'Via dei Cerchi'
      end
    end

    context 'wrong parameter passed', vcr: {
      cassette_name: 'directions/directions/wrong-parameter'
    } do
      let(:params) { { address: 'not a geo-coordinate value' } }

      it 'raises ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when valid origin and directions but no route', vcr: {
      cassette_name: 'directions/directions/not-valid-route'
    } do
      let(:params) do
        {
          origin: ROME,
          destination: SIDNEY
        }
      end

      it 'raises GoogleMapsJuice::ZeroResults' do
        expect { subject }.to raise_error(GoogleMapsJuice::ZeroResults)
      end
    end

    context 'when no parameters passed', vcr: {
      cassette_name: 'directions/directions/no-parameters'
    } do
      let(:params) do
        {}
      end

      it 'raises GoogleMapsJuice::ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when same origin and destination passed', vcr: {
      cassette_name: 'directions/directions/same-origin-destination'
    } do
      let(:params) do
        {
          origin: COLOSSEUM,
          destination: COLOSSEUM
        }
      end

      it 'returns single route composed of one step of 1m and 1min' do
        expect(subject).to be_a GoogleMapsJuice::Directions::Response
        expect(subject.routes).to be_a Array
        expect(subject.routes.size).to be 1
        first_route = subject.first
        expect(first_route).to be_a GoogleMapsJuice::Directions::Response::Route
        expect(first_route.summary).to eq 'Via Celio Vibenna'
        duration = {"text"=>"1 min", "value"=>0}
        expect(first_route.duration).to eq duration
        distance = {"text"=>"1 m", "value"=>0}
        expect(first_route.distance).to eq distance
      end
    end
  end
end
