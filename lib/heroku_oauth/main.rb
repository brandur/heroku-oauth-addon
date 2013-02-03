module HerokuOauth
  Main = Rack::Builder.new do
    use Rack::Instruments
    use Rack::SSL if ENV["RACK_ENV"] == "production"
    run App
  end
end
