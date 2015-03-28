twitter        = require 'simple-twitter'
request        = require 'request'
{EventEmitter} = require 'events'
chalk          = require 'chalk'
express        = require 'express'

class FakeSunTzu
  constructor: ->
    @tweetInterval = 1000*60*60*12
    @quoteUrl      = process.env.URL
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

    self.events.on "sendTweet", (tweet, twitterClient) ->
      twitterClient.post 'statuses/update', 'status': tweet, (error, data) ->
        console.log chalk.bgBlue 'Tweet has been sent successfully' if not error 
        
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
