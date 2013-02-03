require 'bundler'
Bundler.require

$stdout.sync = $stderr.sync = true

require "./lib/heroku_oauth"
run HerokuOauth::Main
