settings =
  port:          process.env.PORT || 9999
  uri:           'http://localhost:8080' # Without trailing /

if process.env.NODE_ENV == 'production'
  settings.uri = 'http://production-domain.com'
  settings.port = process.env.PORT || 80

module.exports = settings