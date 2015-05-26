express = require 'express'
request = require 'request'
pjson   = require '../../../package.json'

router    = module.exports = express.Router()
parserURI = 'http://tmtheme-editor-parser.herokuapp.com/'
#parserURI = 'http://localhost:4567/'

router.get '/', (req, res, next) ->
  view = {
    app_version: pjson.version
  }
  # view.api_url = "http://localhost:#{process.env.PORT || 9999}"
  view.api_url = ""
  res.render 'index', view

router.get '/get_uri', (req, res, next) ->
  res.set 'Content-Type', 'text/plain'
  request req.query.uri, (error, response, body) ->
    if !error && response.statusCode == 200
      res.send body
    else
      res.status 404
      res.send 'Not found'

router.get '/stats', (req, res, next) ->
  view = {}
  view.api_url = ""
  res.render 'stats', view

router.post '/parse', (req, res, next) ->
  request.post parserURI, {form: {text: req.body.text, syntax: req.body.syntax} }, (error, response, body) ->
    res.set 'Content-Type', 'text/plain'
    res.send body
