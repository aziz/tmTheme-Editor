routes = {}
routes.index = (req, res) ->
  view = {
    title: 'Sandbox'
    user: req.user
  }
  res.render 'index', view


routes.get_uri = (req, res) ->
  request  = require 'request'
  console.log req.query.uri
  request req.query.uri, (error, response, body) ->
    if !error && response.statusCode == 200
      res.set('Content-Type', 'text/plain');
      res.send(body)

module.exports = routes


