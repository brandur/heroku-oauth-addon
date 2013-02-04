module HerokuOauth
  module Config
    def self.heroku_api_key
      ENV["HEROKU_API_KEY"] || raise("missing=HEROKU_API_KEY")
    end

    def self.heroku_api_url
      ENV["HEROKU_API_URL"] || raise("missing=HEROKU_API_URL")
    end

    def self.heroku_password
      ENV["HEROKU_PASSWORD"] || raise("missing=HEROKU_PASSWORD")
    end

    def self.heroku_username
      ENV["HEROKU_USERNAME"] || raise("missing=HEROKU_USERNAME")
    end

    def self.production?
      ENV["RACK_ENV"] == "production"
    end

    def self.root
      File.expand_path("../../../", __FILE__)
    end

    def self.sso_salt
      ENV["SSO_SALT"] || raise("missing=SSO_SALT")
    end
  end
end
