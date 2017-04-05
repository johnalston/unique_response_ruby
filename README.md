# UniqueResponseRuby

Official Ruby SDK for Bovitz Unique Response.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unique_response_ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unique_response_ruby


## Setup

Set the following environment variables

UNIQUE_RESPONSE_ACCOUNT_ID
UNIQUE_RESPONSE_AUTH_TOKEN
UNIQUE_RESPONSE_ENDPOINT


## Usage


```ruby
# Initialize a new survey response with the needed attribute values as all strings.  All values are required.
response = UniqueResponse::Response.new("panelist123", "respondent123", "63.116.49.146", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36", "survey123")

# Use the "save" method to post it to the API
response.save 
# => true

# If the "save" method was successful, use "matches" to return an array of matching responses that share the same ip_address and survey_token.  If no matches are found, an empty array is returned.
response.matches
# => [{"created_at"=>1491424044817, "survey_token"=>"survey123", "ip_address"=>"63.116.49.146", "respondent_id"=>"respondent234", "user_agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36", "panelist_id"=>"panelist234", "id"=>"47834810-1a3e-11e7-96bd-e56461835d2d"}, {"created_at"=>1491424066668, "survey_token"=>"survey123", "ip_address"=>"63.116.49.146", "respondent_id"=>"respondent345", "user_agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.37", "panelist_id"=>"panelist345", "id"=>"54897ac0-1a3e-11e7-96bd-e56461835d2d"}]


# Use these convenient methods to detect duplications
response.duplicate_ip_address?
# => true

response.duplicate_user_agent?
# => true

response.duplicate_ip_and_ua?
# => true
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/johnalston/unique_response_ruby.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
