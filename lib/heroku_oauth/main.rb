module HerokuOauth
  Main = Rack::Builder.new do
    use Rack::Instruments
    use Rack::SSL if ENV["RACK_ENV"] == "production"
    run Sinatra::Router.new {
      mount SSO
      mount API
    }
  end
end
