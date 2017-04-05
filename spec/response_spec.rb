require "spec_helper"

RSpec.describe UniqueResponse::Response do

  describe "#valid?" do
    it "should return true if all values are non-empty strings" do
      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "myUserAgent", "surveyToken123")

      expect(response.valid?).to eql true
    end

    it "should return false if any value is nil or missing" do
      response = UniqueResponse::Response.new(nil, "rid123", "1.2.3.4", "myUserAgent", "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", nil, "1.2.3.4", "myUserAgent", "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", "rid123", nil, "myUserAgent", "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", nil, "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "myUserAgent")
      expect(response.valid?).to eql false
    end

    it "should return false if any value is an empty string" do
      response = UniqueResponse::Response.new("", "rid123", "1.2.3.4", "myUserAgent", "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", "", "1.2.3.4", "myUserAgent", "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", "rid123", "", "myUserAgent", "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "", "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "myUserAgent", "")
      expect(response.valid?).to eql false
    end

    it "should return false if any value is not a string" do
      response = UniqueResponse::Response.new(3, "rid123", "1.2.3.4", "myUserAgent", "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", {}, "1.2.3.4", "myUserAgent", "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", "rid123", 0.1, "myUserAgent", "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", [1, 2], "surveyToken123")
      expect(response.valid?).to eql false

      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "myUserAgent", String)
      expect(response.valid?).to eql false
    end

  end

  describe "#save" do
    it "should raise an argument error if response is not valid" do
      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "myUserAgent", "surveyToken123")

      expect(response).to receive(:valid?).and_return(false)

      expect { response.save }.to raise_error ArgumentError
    end

    it "should use a client to save the response and set matches to response data if successful and return true" do
      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "myUserAgent", "surveyToken123")

      client = instance_double UniqueResponse::Client
      expect(UniqueResponse::Client).to receive(:new).and_return(client)
      expect(client).to receive(:save_response).with(response).and_return(true)
      expect(client).to receive(:data).and_return(["match1", "match2"])

      expect(response.save).to eql true
      expect(response.matches).to eql(["match1", "match2"])
    end

    it "should use a client to save the response and return false if unsuccessful" do
      response = UniqueResponse::Response.new("pid123", "rid123", "1.2.3.4", "myUserAgent", "surveyToken123")

      client = instance_double UniqueResponse::Client
      expect(UniqueResponse::Client).to receive(:new).and_return(client)
      expect(client).to receive(:save_response).with(response).and_return(false)

      expect(response.save).to eql false
      expect(response.matches).to eql nil
    end
  end

  describe "#duplicate_ip_address?" do
    it "should return true if matches includes a response with the same ip address" do
      response1 = UniqueResponse::Response.new("pid1", "rid1", "1.2.3.4", "myUserAgent1", "surveyToken")
      response2 = UniqueResponse::Response.new("pid2", "rid2", "1.2.3.4", "myUserAgent2", "surveyToken")
      response3 = UniqueResponse::Response.new("pid3", "rid3", "1.2.3.4", "myUserAgent3", "surveyToken")

      response1.instance_variable_set(:@matches, [response2, response3])

      expect(response1.duplicate_ip_address?).to eql true
    end

    it "should return false if matches includes a response with the same ip address" do
      response1 = UniqueResponse::Response.new("pid1", "rid1", "1.2.3.4", "myUserAgent1", "surveyToken")
      response2 = UniqueResponse::Response.new("pid2", "rid2", "1.2.3.5", "myUserAgent2", "surveyToken")
      response3 = UniqueResponse::Response.new("pid3", "rid3", "1.2.3.6", "myUserAgent3", "surveyToken")

      response1.instance_variable_set(:@matches, [response2, response3])

      expect(response1.duplicate_ip_address?).to eql false
    end

    it "should return false if no matches exist" do
      response1 = UniqueResponse::Response.new("pid1", "rid1", "1.2.3.4", "myUserAgent1", "surveyToken")
      response2 = UniqueResponse::Response.new("pid2", "rid2", "1.2.3.5", "myUserAgent2", "surveyToken")
      response3 = UniqueResponse::Response.new("pid3", "rid3", "1.2.3.6", "myUserAgent3", "surveyToken")

      response1.instance_variable_set(:@matches, [])

      expect(response1.duplicate_ip_address?).to eql false
    end
  end

  describe "#duplicate_user_agent?" do
    it "should return true if matches includes a response with the same user agent" do
      response1 = UniqueResponse::Response.new("pid1", "rid1", "1.2.3.4", "myUserAgent1", "surveyToken")
      response2 = UniqueResponse::Response.new("pid2", "rid2", "1.2.3.5", "myUserAgent2", "surveyToken")
      response3 = UniqueResponse::Response.new("pid3", "rid3", "1.2.3.6", "myUserAgent1", "surveyToken")

      response1.instance_variable_set(:@matches, [response2, response3])

      expect(response1.duplicate_user_agent?).to eql true
    end

    it "should return false if matches includes a response with the same user agent" do
      response1 = UniqueResponse::Response.new("pid1", "rid1", "1.2.3.4", "myUserAgent1", "surveyToken")
      response2 = UniqueResponse::Response.new("pid2", "rid2", "1.2.3.4", "myUserAgent2", "surveyToken")
      response3 = UniqueResponse::Response.new("pid3", "rid3", "1.2.3.4", "myUserAgent3", "surveyToken")

      response1.instance_variable_set(:@matches, [response2, response3])

      expect(response1.duplicate_user_agent?).to eql false
    end

    it "should return false if no matches exist" do
      response1 = UniqueResponse::Response.new("pid1", "rid1", "1.2.3.4", "myUserAgent1", "surveyToken")
      response2 = UniqueResponse::Response.new("pid2", "rid2", "1.2.3.5", "myUserAgent1", "surveyToken")
      response3 = UniqueResponse::Response.new("pid3", "rid3", "1.2.3.6", "myUserAgent1", "surveyToken")

      response1.instance_variable_set(:@matches, [])

      expect(response1.duplicate_user_agent?).to eql false
    end
  end

  describe "#duplicate_ip_and_ua?" do
    it "should return true if matches includes a response with the same ip address and user agent" do
      response1 = UniqueResponse::Response.new("pid1", "rid1", "1.2.3.4", "myUserAgent1", "surveyToken")
      response2 = UniqueResponse::Response.new("pid2", "rid2", "1.2.3.5", "myUserAgent1", "surveyToken")
      response3 = UniqueResponse::Response.new("pid3", "rid3", "1.2.3.4", "myUserAgent1", "surveyToken")

      response1.instance_variable_set(:@matches, [response2, response3])

      expect(response1.duplicate_ip_and_ua?).to eql true
    end

    it "should return false if matches includes a response with the same ip address and user agent" do
      response1 = UniqueResponse::Response.new("pid1", "rid1", "1.2.3.4", "myUserAgent1", "surveyToken")
      response2 = UniqueResponse::Response.new("pid2", "rid2", "1.2.3.4", "myUserAgent2", "surveyToken")
      response3 = UniqueResponse::Response.new("pid3", "rid3", "1.2.3.4", "myUserAgent3", "surveyToken")

      response1.instance_variable_set(:@matches, [response2, response3])

      expect(response1.duplicate_ip_and_ua?).to eql false
    end

    it "should return false if no matches exist" do
      response1 = UniqueResponse::Response.new("pid1", "rid1", "1.2.3.4", "myUserAgent1", "surveyToken")
      response2 = UniqueResponse::Response.new("pid2", "rid2", "1.2.3.5", "myUserAgent1", "surveyToken")
      response3 = UniqueResponse::Response.new("pid3", "rid3", "1.2.3.6", "myUserAgent1", "surveyToken")

      response1.instance_variable_set(:@matches, [])

      expect(response1.duplicate_ip_and_ua?).to eql false
    end
  end

end
