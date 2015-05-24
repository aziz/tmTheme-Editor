routes = {}
pjson = require('../package.json')

routes.index = (req, res) ->
  view = {app_version: pjson.version}
  res.render 'index', view

routes.get_uri = (req, res) ->
  request  = require 'request'
  res.set 'Content-Type', 'text/plain'
  request req.query.uri, (error, response, body) ->
    if !error && response.statusCode == 200
      res.send body
    else
      res.status 404
      res.send 'Not found'

routes.stats = (req, res) ->
  view = {}
  res.render 'stats', view

routes.parse = (req, res) ->
  request  = require 'request'
  #parserURI = 'http://localhost:4567/'
  parserURI = 'http://tmtheme-editor-parser.herokuapp.com/'
  request.post parserURI, {form: {text: req.body.text, syntax: req.body.syntax} }, (error, response, body) ->
    res.set 'Content-Type', 'text/plain'
    res.send body

module.exports = routes
