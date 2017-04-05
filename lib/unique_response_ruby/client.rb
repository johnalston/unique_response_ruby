module UniqueResponse
  require 'net/http'
  require 'net/https'
  require 'json'

  class Client
    attr_reader :successful, :data

    HTTP_HEADERS = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Accept-Charset' => 'utf-8',
        'User-Agent' => 'unique_response_ruby'
    }

    def initialize
      @account_id = ENV['UNIQUE_RESPONSE_ACCOUNT_ID']
      @auth_token = ENV['UNIQUE_RESPONSE_AUTH_TOKEN']
      if @account_id.nil? || @auth_token.nil?
        raise ArgumentError, 'Account SID and auth token are required'
      end
    end

    def save_response(response)
      @uri = URI(ENV['UNIQUE_RESPONSE_ENDPOINT'])
      @http_request = Net::HTTP::Post.new @uri.path, HTTP_HEADERS
      @http_request.body = response.to_h.to_json
      perform_request
    end

    private
      def perform_request
        http_response = Net::HTTP.start(@uri.host, @uri.port, use_ssl: true) do |http|
          http.request @http_request
        end

        case http_response
        when Net::HTTPSuccess, Net::HTTPRedirection
          body = JSON.parse http_response.body
          if @successful = body["successful"] || false
            @data = body["data"]
          else
            @data = "Error saving response: #{body["data"].to_json}"
          end
        else
          @data = "#{http_response.code}: #{http_response.body}"
          @successful = false
        end

        return @successful
      end

  end
end
