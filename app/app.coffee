express         = require 'express'
http            = require 'http'
fs              = require 'fs'
path            = require 'path'
less            = require 'less'
sugar           = require 'sugar'
template_engine = require 'ejs-locals'
assets_manager  = require 'connect-assets'
settings        = require './config'
routes          = require './routes'

app = module.exports = express()

app.configure ->
  app.engine 'ejs', template_engine
  app.set 'port', settings.port
  app.set 'views', "#{__dirname}/templates"
  app.set 'view engine', 'ejs'
  app.use express.compress()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.methodOverride()
  app.use assets_manager("buildDir": "public/assets/", "paths": ["app/assets/js","app/assets/css"])
  app.use app.router
  app.use express.static "#{__dirname}/../public"

app.configure 'development', ->
  app.use express.logger('dev')
  app.use express.errorHandler('dumpExceptions': true, 'showStack': true)

app.configure 'production', ->
  # log = fs.createWriteStream 'log/production.log', {flags: 'w'}
  app.use express.errorHandler()
  # app.use express.logger(stream: log)

app.get '/', routes.index
app.get '/get_uri', routes.get_uri
app.get '/stats', routes.stats
app.post '/parse', routes.parse

http.createServer(app).listen settings.port, ->
  console.log "Express server listening on port #{settings.port} in '#{app.get('env')}' environment"
