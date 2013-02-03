module HerokuOauth
  class API < Sinatra::Base
    @@resources = []

    Resource = Class.new(OpenStruct)

    helpers do
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && 
        @auth.credentials == [ENV['HEROKU_USERNAME'], ENV['HEROKU_PASSWORD']]
      end

      def json_body
        @json_body ||= JSON.parse(request.body.read || "{}")
      end

      def get_resource
        @@resources.find {|u| u.id == params[:id].to_i } or halt 404, 'resource not found'
      end
    end

    # provision
    post '/heroku/resources' do
      protected!
      status 201
      resource = Resource.new(:id => @@resources.size + 1, 
                              :plan => json_body.fetch('plan', 'test'))
      @@resources << resource
      {
        id: resource.id,
        config: {
          "HEROKU_ID"     => '123',
          "HEROKU_SECRET" => '456abc',
        }
      }.to_json
    end

    # deprovision
    delete '/heroku/resources/:id' do
      protected!
      @@resources.delete(get_resource)
      "ok"
    end

    # plan change
    put '/heroku/resources/:id' do
      protected!
      resource = get_resource 
      resource.plan = json_body['plan']
      {}.to_json
    end
  end
end
