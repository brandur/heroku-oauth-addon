module HerokuOauth
  class SSO < Sinatra::Base
    use Rack::Session::Cookie, secret: ENV['SSO_SALT']

    @@resources = []

    helpers do
      def get_resource
        @@resources.find {|u| u.id == params[:id].to_i } or halt 404, 'resource not found'
      end
    end

    # sso landing page
    get "/" do
      halt 403, 'not logged in' unless session[:heroku_sso]
      #response.set_cookie('heroku-nav-data', value: session[:heroku_sso])
      @resource = session[:resource]
      @email    = session[:email]
      haml :index
    end

    def sso
      pre_token = params[:id] + ':' + ENV['SSO_SALT'] + ':' + params[:timestamp]
      token = Digest::SHA1.hexdigest(pre_token).to_s
      halt 403 if token != params[:token]
      halt 403 if params[:timestamp].to_i < (Time.now - 2*60).to_i

      halt 404 unless session[:resource]   = get_resource

      response.set_cookie('heroku-nav-data', value: params['nav-data'])
      session[:heroku_sso] = params['nav-data']
      session[:email]      = params[:email]

      redirect '/'
    end

    # sso sign in
    get "/heroku/resources/:id" do
      sso
    end

    post '/sso/login' do
      puts params.inspect
      sso
    end
  end
end
