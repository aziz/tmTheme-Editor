routes = {}
routes.index = (req, res) ->
  view = {
    title: 'Sandbox'
    user: req.user
  }
  res.render 'index', view

module.exports = routes


