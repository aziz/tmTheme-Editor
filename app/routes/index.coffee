routes = {}

routes.index = (req, res) ->
  view = {}
  res.render 'index', view

routes.get_uri = (req, res) ->
  request  = require 'request'
  request req.query.uri, (error, response, body) ->
    if !error && response.statusCode == 200
      res.set 'Content-Type', 'text/plain'
      res.send body

module.exports = routes


