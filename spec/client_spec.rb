require "spec_helper"

RSpec.describe UniqueResponse::Client do

  it "requires an account_id and auth_token" do
    expect { UniqueResponse::Client.new }.to_not raise_error

    ENV['UNIQUE_RESPONSE_ACCOUNT_ID'] = nil
    ENV['UNIQUE_RESPONSE_AUTH_TOKEN'] = "myAuthToken"
    auth_token = "myAuthToken"
    expect { UniqueResponse::Client.new }.to raise_error ArgumentError

    ENV['UNIQUE_RESPONSE_ACCOUNT_ID'] = "myAccountId"
    ENV['UNIQUE_RESPONSE_AUTH_TOKEN'] = nil
    auth_token = nil
    expect { UniqueResponse::Client.new }.to raise_error ArgumentError
  end

  describe "#save_response" do
    it "should post the response to the API endpoint, return true if saved successfully, and set data to response value" do
      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "myUserAgent", "surveyToken123")
      client = UniqueResponse::Client.new
      ENV['UNIQUE_RESPONSE_ENDPOINT'] = "https://www.example.com/response"
      stub_request(:post, "https://www.example.com/response").with(body: response.to_h.to_json).to_return(status: 201, body: { successful: true, data: [ "test1", "test2" ] }.to_json, headers: { "Content-Type" => "application/json" })

      expect(client.save_response(response)).to eql true
      expect(client.successful).to eql true
      expect(client.data).to eql [ "test1", "test2" ]
    end

    it "should post the response to the API endpoint, return false if not saved successfully, and set data to original response" do
      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "myUserAgent", "surveyToken123")
      client = UniqueResponse::Client.new
      ENV['UNIQUE_RESPONSE_ENDPOINT'] = "https://www.example.com/response"
      stub_request(:post, "https://www.example.com/response").with(body: response.to_h.to_json).to_return(status: 201, body: { successful: false, data: response.to_h }.to_json, headers: { "Content-Type" => "application/json" })

      expect(client.save_response(response)).to eql false
      expect(client.successful).to eql false
      expect(client.data).to eql "Error saving response: #{response.to_h.to_json}"
    end

    it "should post the response to the API endpoint and return false if bad response status" do
      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "myUserAgent", "surveyToken123")
      client = UniqueResponse::Client.new
      ENV['UNIQUE_RESPONSE_ENDPOINT'] = "https://www.example.com/response"
      stub_request(:post, "https://www.example.com/response").with(body: response.to_h.to_json).to_return(status: 500, body: "Internal server error")

      expect(client.save_response(response)).to eql false
      expect(client.successful).to eql false
      expect(client.data).to eql "500: Internal server error"
    end
  end

end
