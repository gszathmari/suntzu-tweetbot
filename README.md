# suntzu-tweetbot

Tweets randomly generated quotes from [suntzu-generator](https://github.com/gszathmari/suntzu-generator)

# Installation

* [Deploy application into Heroku](https://devcenter.heroku.com/articles/getting-started-with-nodejs) as it is

# Configuration
Set environmental variables
* **CONSUMER_KEY** - Twitter consumer key
* **CONSUMER_SECRET** - Twitter consumer secret
* **ACCESS_TOKEN** - Twitter access token
* **ACCESS_SECRET** - Twitter access secret
* **SUNTZU_QUOTE_URL** - URL of [suntzu-generator](https://github.com/gszathmari/suntzu-generator) API

# Miscelleanous
Healthcheck for Uptime Robot, Pingdom etc.
```bash
$ curl https://<application>.herokuapp.com/
```
Uptime healthcheck is also available
```bash
$ curl https://<application>.herokuapp.com/healthcheck
```
