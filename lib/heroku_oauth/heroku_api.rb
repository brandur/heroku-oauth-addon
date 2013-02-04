require "base64"

module HerokuOauth
  class HerokuAPI < Excon::Connection
    def initialize(options={})
      headers = {
        "Accept" => "application/vnd.heroku+json; version=3"
      }
      authorization = Base64.urlsafe_encode64(":#{ENV["HEROKU_API_KEY"]}")
      headers["Authorization"] = "Basic #{authorization}"
      super(ENV["HEROKU_API_URL"], headers: headers,
        instrumentor: ExconInstrumentor.new(id: options[:request_id]))
    end
  end
end
