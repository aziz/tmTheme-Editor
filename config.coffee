settings = {}
if process.env.NODE_ENV == 'production'
  settings.port = process.env.PORT || 80
else
  settings.port = process.env.PORT || 9999

module.exports = settings