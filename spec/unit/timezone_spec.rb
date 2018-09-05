require 'spec_helper'

RSpec.describe GoogleMapsJuice::Timezone do
  let(:client) { GoogleMapsJuice::Client.new }
  let(:timezone) { GoogleMapsJuice::Timezone.new(client) }
  let(:endpoint) { '/timezone/json' }

  describe '#by_location' do

    subject { timezone.by_location(params) }


    context 'with bad params' do

      context 'when params is not a Hash' do
        let(:params) { 'foobar' }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError, 'Hash argument expected')
        end
      end

      context 'when some unsupported param is passed' do
        let(:params) { { latitude: 35.9489566, foo: 'hey', bar: 'man' } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError,
            'The following params are not supported: foo, bar')
        end
      end

      context 'when some required param is not passed' do
        let(:params) { { latitude: 35.9489566 } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError,
            'All of the following params are required: latitude, longitude')
        end
      end

      context 'when wrong timestamp value is passed' do
        let(:params) { { latitude: 35, longitude: -85, timestamp: 123456 } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError,
            'Timestamp must be a Time instance')
        end
      end

      context 'when wrong latitude value is passed' do
        let(:params) { { latitude: -90.1, longitude: -85 } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError,
            'Wrong latitude value')
        end
      end

      context 'when wrong value is passed as longitude' do
        let(:params) { { latitude: 35, longitude: -180.1 } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError,
            'Wrong longitude value')
        end
      end
    end


    context 'with good params' do

      before do
        expect(client).to receive(:get).with(endpoint, req_params).and_return(response)
      end

      let(:response) { response_fixture('timezone/success') }
      let(:params) { { latitude: 35.9489566, longitude: -85.0269014, timestamp: Time.now } }
      let(:req_params) { { location: '35.9489566,-85.0269014', timestamp: params[:timestamp].to_i } }

      it 'returns successful result' do
        expect(subject).to be_a GoogleMapsJuice::Timezone::Response
        expect(subject.timezone_id).to eq 'America/Chicago'
        expect(subject.timezone_name).to eq 'Central Daylight Time'
        expect(subject.raw_offset).to eq -21600
        expect(subject.dst_offset).to eq 3600
      end

    end

  end

end
