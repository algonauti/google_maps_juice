require 'spec_helper'

RSpec.describe GoogleMapsJuice::Endpoint, webmock: true do

  before do

    class SomeEndpoint < GoogleMapsJuice::Endpoint
      ENDPOINT = '/some-endpoint'

      def invoke(params)
        response_text = @client.get(ENDPOINT, params)
        response = JSON.parse(response_text, object_class: GoogleMapsJuice::Endpoint::Response)
        detect_errors(response)
      end
    end

  end


  after { Object.send :remove_const, :SomeEndpoint }


  describe '#detect_errors' do
    let(:client) { GoogleMapsJuice::Client.new }
    let(:some_endpoint) { SomeEndpoint.new(client) }
    let(:params) { { foo: 'bar', x: 123 } }
    let(:base_url) { 'https://maps.googleapis.com/maps/api' }
    let(:url_pattern) { Regexp.new("#{base_url}#{SomeEndpoint::ENDPOINT}*") }

    before { stub_request(:get, url_pattern).to_return(body: response, status: 200) }

    subject { some_endpoint.invoke(params) }

    context 'when response returns zero results' do
      let(:response) { response_fixture('zero-results') }

      it 'raises GoogleMapsJuice::ZeroResults' do
        expect { subject }.to raise_error(GoogleMapsJuice::ZeroResults)
      end
    end

    context 'when response contains limit error' do
      let(:response) { response_fixture('limit-error') }

      it 'raises GoogleMapsJuice::ResponseError' do
        expect { subject }.to raise_error(GoogleMapsJuice::ApiLimitError,
          'OVER_QUERY_LIMIT - You have exceeded your daily request quota for this API.')
      end
    end

    context 'when response contains error' do
      let(:response) { response_fixture('error') }

      it 'raises GoogleMapsJuice::ResponseError' do
        expect { subject }.to raise_error(GoogleMapsJuice::ResponseError,
          'API UNKNOWN_ERROR - A server error occurred, please retry later')
      end
    end

    context "when response doesn't contain any error" do
      let(:response) { response_fixture('success') }

      it 'returns successful response' do
        expect(subject).to be_a GoogleMapsJuice::Endpoint::Response
        expect(subject.error?).to be false
        expect(subject.results).to be_a Array
      end
    end
  end

end
