require "bundler/setup"
require "unique_response_ruby"
require "webmock/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    ENV['UNIQUE_RESPONSE_ACCOUNT_ID'] = "myAccountId"
    ENV['UNIQUE_RESPONSE_AUTH_TOKEN'] = "myAuthToken"
    ENV['UNIQUE_RESPONSE_ENDPOINT'] = "https://www.example.com/response"
  end

end
