require "multi_json"
require "sinatra/base"
require "sinatra/namespace"

class HerokuAPIStub < Sinatra::Base
  register Sinatra::Namespace

  SampleClient = {
    id:           123,
    name:         "Third-party Heroku OAuth Client",
    description:  <<-eos,
A client provisioned from the heroku-oauth addon. Change its name and
description using `heroku addons:open heroku-oauth` from your app directory.
    eos
    redirect_uri: "https://example.com/oauth/callback/heroku",
    secret:       "9184fe8c92b16e73777b54fb54810cd9395448c388f22d3e",
    trusted:      false,
  }.freeze

  configure do
    set :raise_errors,    true
    set :show_exceptions, false
  end

  helpers do
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def auth_credentials
      auth.provided? && auth.basic? ? auth.credentials : nil
    end

    def authorized!
      halt(401, "Unauthorized") unless auth_credentials
    end
  end

  post "/oauth/clients" do
    status(201)
    MultiJson.encode(SampleClient)
  end

  get "/oauth/clients/:id" do |id|
    status(200)
    MultiJson.encode(SampleClient)
  end

  delete "/oauth/clients/:id" do |id|
    status(200)
    MultiJson.encode(SampleClient)
  end
end

if __FILE__ == $0
  $stdout.sync = $stderr.sync = true
  HerokuAPIStub.run! port: ENV["PORT"]
end
