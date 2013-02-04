module HerokuOauth
  Main = Rack::Builder.new do
    use Rack::Instruments
    use Rack::SSL if Config.production?
    run Sinatra::Router.new {
      mount SSO
      mount API
    }
  end
end
