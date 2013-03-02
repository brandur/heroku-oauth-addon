require "base64"

module HerokuOauth
  class HerokuAPI < Excon::Connection
    def initialize(options={})
      request_ids = options[:request_ids] ?
        options[:request_ids].join(",") : nil
      headers = {
        "Accept"     => "application/vnd.heroku+json; version=3",
        "Request-ID" => request_ids,
      }
      authorization = Base64.urlsafe_encode64(":#{Config.heroku_api_key}")
      headers["Authorization"] = "Basic #{authorization}"
      super(Config.heroku_api_url, headers: headers,
        instrumentor: ExconInstrumentor.new(id: request_ids))
    end
  end
end
