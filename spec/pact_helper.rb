require 'pact/consumer/rspec'
require 'restify'
require 'nexboard_api'

Pact.service_consumer "OpenHPI" do
  has_pact_with "nexboard" do
    puts "Starting mock nexboard server"
    mock_service :nexboard do
      port 1234
    end
  end
end