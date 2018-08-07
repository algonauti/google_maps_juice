require "bundler/setup"
require 'webmock/rspec'
require "google_maps_juice"
require 'dotenv/load'

Dotenv.overload('.env', '.env.test')

GoogleMapsJuice.configure do |config|
  config.api_key = ENV.fetch('API_KEY') { 'dummy_api_key' }
end

module FixtureHelpers
  def response_fixture(name)
    File.open("spec/fixtures/response/#{name}.json").read
  end
end

module VCRTestHelpers
  extend ActiveSupport::Concern

  included do
    require 'vcr'

    VCR.configure do |vcr|
      vcr.cassette_library_dir = 'spec/fixtures/vcr'
      vcr.default_cassette_options = { allow_playback_repeats: true }
      vcr.hook_into :excon
      vcr.configure_rspec_metadata!
      vcr.allow_http_connections_when_no_cassette = true
      vcr.ignore_localhost = true
      vcr.filter_sensitive_data('<API_KEY>') { GoogleMapsJuice.config.api_key }
    end
  end
end

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FixtureHelpers
  config.include VCRTestHelpers, vcr: true
end
