module UniqueResponse

  Response = Struct.new(:panelist_id, :respondent_id, :ip_address, :user_agent, :survey_token) do
    attr_reader :matches

    def valid?
      values.map { |value| value.is_a?(String) && !value.empty? }.reduce(:&)
    end

    def save
      raise ArgumentError unless valid?

      client = Client.new
      if client.save_response(self)
        @matches = client.data
        true
      else
        false
      end
    end

    def duplicate_ip_address?
      @matches.any? { |match| match["ip_address"] == ip_address }
    end

    def duplicate_user_agent?
      @matches.any? { |match| match["user_agent"] == user_agent }
    end

    def duplicate_ip_and_ua?
      @matches.any? { |match| match["ip_address"] == ip_address && match["user_agent"] == user_agent }
    end
  end

end
