twitter        = require 'simple-twitter'
request        = require 'request'
{EventEmitter} = require 'events'
chalk          = require 'chalk'

class FakeSunTzu
  constructor: ->
    @tweetInterval = 1000*60*60*12 // 12 hours
    @quoteUrl      = process.env.URL
    @events        = new EventEmitter
    @twitterClient = new twitter process.env.CONSUMER_KEY,
                                 process.env.CONSUMER_SECRET,
                                 process.env.ACCESS_TOKEN,
                                 process.env.ACCESS_SECRET

  run: ->
    self = @

    self.events.on "fetchQuote", (options) ->
      request options, (error, response, body) ->
        if not error and response.statusCode == 200
          self.events.emit "sendTweet", JSON.parse(body).quote, response.request.twitterClient

    self.events.on "sendTweet", (tweet, twitterClient) ->
      twitterClient.post 'statuses/update', 'status': tweet, (error, data) ->
        console.log chalk.bgBlue 'Tweet has been sent successfully' if not error 
        
    setInterval =>
      options =
        url: @quoteUrl
        twitterClient: @twitterClient
      self.events.emit 'fetchQuote', options
    , @tweetInterval

session = new FakeSunTzu
session.run()