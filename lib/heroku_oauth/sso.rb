module HerokuOauth
  class SSO < Sinatra::Base
    set :views, "#{Config.root}/views"

    use Rack::Session::Cookie, secret: Config.sso_salt
    use Rack::Csrf, skip: ["POST:/sso/login"]

    get "/heroku/resources/:id" do |id|
      sso!
      log :get_client, id: id do
        @client = Models::Client.first(id: id) || halt(404)
        @client_hash = MultiJson.decode(api.get(
          expects: 200,
          path: "/oauth/clients/#{@client.client_id}").body)
        slim :resource
      end
    end

    post "/heroku/resources/:id" do
      sso!
      log :update_client, id: id do
        @client = Models::Client.first(id: id) || halt(404)
        @client_hash = MultiJson.decode(api.put(
          expects: 200,
          path: "/oauth/clients/#{@client.client_id}",
          query: {
            description:  params[:description],
            name:         params[:name],
            redirect_uri: params[:redirect_uri],
          }).body)
        slim :resource
      end
    end

    post '/sso/login' do
      sso!
      redirect to("/heroku/resources/#{params[:id]}")
    end

    private

    def api
      @api ||= HerokuAPI.new(request_id: request.env["REQUEST_ID"])
    end

    def check_timestamp!
      halt 403 if params[:timestamp].to_i < (Time.now - 2*60).to_i
    end

    def check_token!
      pre_token = params[:id] + ':' + Config.sso_salt + ':' + params[:timestamp]
      token = Digest::SHA1.hexdigest(pre_token).to_s
      halt 403 if token != params[:token]
    end

    def log(action, attributes={}, &block)
      attributes.merge!(request_id: request.env["REQUEST_ID"])
      Slides.log(action, attributes, &block)
    end

    def sso!
      return if session[:email]

      check_token!
      check_timestamp!

      response.set_cookie('heroku-nav-data', value: params['nav-data'])
      session[:heroku_sso] = params['nav-data']
      session[:email]      = params[:email]
    end
  end
end
