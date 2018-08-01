require 'spec_helper'

RSpec.describe GoogleMapsJuice::Client do
  let(:base_url) { 'https://maps.googleapis.com/maps/api' }

  describe '.get' do
    let(:endpoint) { '/my-endpoint' }
    let(:params) { { foo: 'bar', x: 123 } }
    let(:query_string) do
      params.merge({ api_key: GoogleMapsJuice.config.api_key }).to_query
    end

    before { stub_request(:get, Regexp.new("#{base_url}#{endpoint}*")) }

    it 'calls API endpoint with params' do
      described_class.get(endpoint, params)
      expect(a_request(:get, "#{base_url}#{endpoint}?#{query_string}")).to have_been_made
    end
  end

end
