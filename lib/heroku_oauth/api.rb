module HerokuOauth
  class API < Sinatra::Base
    before do
      protected!
    end

    post '/heroku/resources' do
      begin
        log :provision do
          client = MultiJson.decode(api.post(
            expects: 201,
            path: "/oauth/clients",
            query: {
              name:         "Third-party Heroku OAuth Client",
              redirect_uri: "https://example.com/oauth/callback/heroku",
              description:  <<-eos }).body)
A client provisioned from the heroku-oauth addon. Change its name and
description using `heroku addons:open heroku-oauth` from your app directory.
              eos
          status 201
          MultiJson.encode({
            id: client["id"],
            config: {
              "HEROKU_OAUTH_ID"     => client["id"].to_s,
              "HEROKU_OAUTH_SECRET" => client["secret"],
            }
          })
        end
      rescue Excon::Errors::Error
        status 503
        "There was a problem communicating with the Heroku API. " +
        "Please try again later."
      end
    end

    delete '/heroku/resources/:id' do |id|
      begin
        log :deprovision, id: id do
          api.delete(path: "/oauth/clients/#{id}", expects: 200)
          MultiJson.encode({})
        end
      rescue Excon::Errors::Error
        status 503
        "There was a problem communicating with the Heroku API. " +
        "Please try again later."
      end
    end

    put '/heroku/resources/:id' do |id|
      begin
        log :change_plan, id: id, new_plan: json_body["plan"] do
          MultiJson.encode({})
        end
      rescue Excon::Errors::Error
        status 503
        "There was a problem communicating with the Heroku API. " +
        "Please try again later."
      end
    end

    private

    def api
      @api ||= HerokuAPI.new(request_id: request.env["REQUEST_ID"])
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && 
      @auth.credentials == [ENV['HEROKU_USERNAME'], ENV['HEROKU_PASSWORD']]
    end

    def get_resource
      @@resources.find {|u| u.id == params[:id].to_i } or halt 404, 'resource not found'
    end

    def json_body
      @json_body ||= MultiJson.decode(request.body.read || "{}")
    end

    def log(action, attributes={}, &block)
      attributes.merge!(request_id: request.env["REQUEST_ID"])
      Slides.log(action, attributes, &block)
    end

    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end
  end
end
