require "bundler/setup"
require 'webmock/rspec'
require "google_maps_juice"

GoogleMapsJuice.configure do |config|
  config.api_key = 'dummy_api_key'
end

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
