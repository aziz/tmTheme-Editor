express  = require 'express'
settings = require './config'
routes   = require './app/routes'
http     = require 'http'
fs       = require 'fs'
path     = require 'path'
less     = require 'less'
sugar    = require 'sugar'

template_engine = require 'ejs-locals'
gzip            = require 'connect-gzip'
assets_manager  = require 'connect-assets'

app = module.exports = express()

app.configure ->
  app.engine 'ejs', template_engine
  app.set 'port', settings.port
  app.set 'views', "#{__dirname}/app/templates"
  app.set 'view engine', 'ejs'
  app.use express.compress()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.methodOverride()
  app.use assets_manager("buildDir": "public", "src": "app/assets/")
  app.use app.router
  app.use express.static "#{__dirname}/public"

app.configure 'development', ->
  app.use express.logger('dev')
  app.use express.errorHandler('dumpExceptions': true, 'showStack': true)

app.configure 'production', ->
  log = fs.createWriteStream 'log/production.log', {flags: 'w'}
  app.use gzip.gzip()
  app.use express.errorHandler()
  app.use express.logger(stream: log)

app.get '/', routes.index
app.get '/get_uri', routes.get_uri
app.get '/stats', routes.stats
app.get '/partials/:partialName', routes.partials

http.createServer(app).listen settings.port, ->
  console.log "Express server listening on port #{settings.port} in '#{app.get('env')}' environment"
