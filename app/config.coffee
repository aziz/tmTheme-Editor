config = {}
config.assets = ["app/assets/js", "app/assets/css", "bower_components"]
if process.env.NODE_ENV == 'production'
  config.port = process.env.PORT || 80
else
  config.port = process.env.PORT || 9999

module.exports = config
