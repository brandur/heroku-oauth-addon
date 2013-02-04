require 'bundler'
Bundler.require

$stdout.sync = $stderr.sync = true

DB = Sequel.connect(ENV["DATABASE_URL"] || raise("missing=DATABASE_URL"))

require "./lib/heroku_oauth"
run HerokuOauth::Main
