require "base64"

module HerokuOauth
  class HerokuAPI < Excon::Connection
    def initialize(options={})
      headers = {
        "Accept" => "application/vnd.heroku+json; version=3"
      }
      authorization = Base64.urlsafe_encode64(":#{Config.heroku_api_key}")
      headers["Authorization"] = "Basic #{authorization}"
      super(Config.heroku_api_url, headers: headers,
        instrumentor: ExconInstrumentor.new(id: options[:request_id]))
    end
  end
end
