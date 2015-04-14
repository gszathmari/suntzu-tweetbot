twitter        = require 'simple-twitter'
request        = require 'request'
{EventEmitter} = require 'events'
chalk          = require 'chalk'
express        = require 'express'

class FakeSunTzu
  constructor: ->
    @tweetInterval = process.env.TWEET_INTERVAL_HOURS || 12
    @tweetInterval = @tweetInterval * 1000 * 60 * 60
    @quoteUrl      = process.env.URL
    @snitchUrl     = process.env.DEADMANSSNITCH_URL
    @events        = new EventEmitter
    @twitterClient = new twitter process.env.CONSUMER_KEY,
                                 process.env.CONSUMER_SECRET,
                                 process.env.ACCESS_TOKEN,
                                 process.env.ACCESS_SECRET

  run: ->
    self = @
    app  = express()

    self.events.on "fetchQuote", (options) ->
      request options, (error, response, body) ->
        if not error and response.statusCode == 200
          self.events.emit "sendTweet", JSON.parse(body).quote, response.request.twitterClient
        else
          console.log chalk.bgRed 'Error: ' + error.data.toString()
          
    self.events.on "sendTweet", (tweet, twitterClient) ->
      twitterClient.post 'statuses/update', 'status': tweet, (error, data) ->
        if not error
          # Log success to Dead Man's Snitch
          request.get self.snitchUrl if self.snitchUrl
          console.log chalk.bgBlue 'Tweet has been sent successfully'
        else
          console.log chalk.bgRed 'Error: ' + error.data.toString()
        
    setInterval =>
      options =
        url: @quoteUrl
        twitterClient: @twitterClient
      self.events.emit 'fetchQuote', options
    , @tweetInterval

    app.get '/', (req, res) ->
      res.send 'OK'

    server = app.listen app.listen process.env.PORT or 5000, ->
      address = server.address().address
      port    = server.address().port
      console.log chalk.green "Express server listening on http://" + address + ":" + port

session = new FakeSunTzu
session.run()
