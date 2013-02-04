heroku-oauth
============

A Heroku addon implementation providing an easy way to create and register a
Heroku OAuth client to an App.

## Development

The `Procfile` contains an API stub that will respond with reasonable sample
data so that something like a `kensa test all` can be run against a local
development instance of the addon.

``` bash
cp addon-manifest.json.sample
cp .env.sample .env
bundle install
bundle exec sequel -m db/migrate postgres://localhost/heroku-oauth-development
foreman start
kensa test all
```

## Platform Deploy

Real configuration values will be required for a platform deploy

``` bash
heroku create
heroku addons:add heroku-postgresql:basic
heroku config:add HEROKU_API_KEY=  # Heroku API key used to create OAuth clients
heroku config:add HEROKU_API_URL=  # URL of the Heroku API
heroku config:add HEROKU_USERNAME= # Username for the provider interface; same as addon name
heroku config:add HEROKU_PASSWORD= # Password for the provider interface; whatever's in addon-manifest.json
heroku config:add SSO_SALT=        # Salt for single sign-on; whatever's in addon-manifest.json
git push heroku master
heroku run bundle exec sequel -m db/migrate \$DATABASE_URL
```
