heroku-oauth
============

A Heroku addon implementation providing an easy way to create and register a Heroku OAuth client to an App.

## Development

``` bash
cp .env.sample .env
foreman start
```

## Platform Deploy

``` bash
heroku create
heroku config:add HEROKU_API_KEY=
heroku config:add HEROKU_API_URL=
heroku config:add HEROKU_USERNAME=
heroku config:add HEROKU_PASSWORD=
heroku config:add SSO_SALT=
git push heroku master
```
