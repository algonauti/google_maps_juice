require 'spec_helper'

RSpec.describe GoogleMapsJuice::Client, webmock: true do
  let(:base_url) { 'https://maps.googleapis.com/maps/api' }

  describe '.get' do
    let(:endpoint) { '/my-endpoint' }
    let(:params) { { foo: 'bar', x: 123 } }
    let(:query_string) do
      params.merge({ key: GoogleMapsJuice.config.api_key }).to_query
    end
    let(:url_pattern) { Regexp.new("#{base_url}#{endpoint}*") }

    context 'request' do
      before { stub_request(:get, Regexp.new("#{base_url}#{endpoint}*")) }

      it 'calls API endpoint with params' do
        described_class.get(endpoint, params)
        expect(a_request(:get, "#{base_url}#{endpoint}?#{query_string}")).to have_been_made
      end
    end

    context 'response' do
      subject { described_class.get(endpoint, params) }

      context 'when HTTP response status is successful' do
        before { stub_request(:get, url_pattern).to_return(body: "I'm successful!", status: 200) }

        it 'returns response body' do
          expect(subject).to eq "I'm successful!"
        end
      end

      context 'when HTTP response status is not successful' do
        before { stub_request(:get, url_pattern).to_return(body: "Uh-oh, I crashed!", status: 503) }

        it 'raises GoogleMapsJuice::ResponseError' do
          expect { subject }.to raise_error(GoogleMapsJuice::ResponseError,
            'HTTP 503 - Uh-oh, I crashed!'
          )
        end
      end
    end

  end

end
