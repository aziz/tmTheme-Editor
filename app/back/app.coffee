express         = require 'express'
bodyParser      = require 'body-parser'
methodOverride  = require 'method-override'
logger          = require 'morgan'
errorhandler    = require 'errorhandler'
cookieParser    = require 'cookie-parser'
session         = require 'express-session'
compress        = require 'compression'
fs              = require 'fs'
less            = require 'less'
assets_manager  = require 'connect-assets'
ECT             = require 'ect'

config            = require './config'
ngTemplatesEngine = require './lib/ngtemplate'
pages_controller  = require './controllers/pages_controller'


app = module.exports = express()

app.set 'view engine', 'html'
app.set 'views', "#{__dirname}/views"
app.set 'port', config.port
app.set 'x-powered-by', false

app.engine 'html', ECT(watch: true, root: "#{__dirname}/views", ext : '.html').render

app.use compress()
app.use express.static "#{__dirname}/../front/public"
app.use bodyParser.json()
app.use bodyParser.urlencoded({extended: true })
app.use cookieParser(config.cookie_secret)
app.use methodOverride()

register_mincer_engines = (instance) ->
  instance.environment.registerEngine('.html',  ngTemplatesEngine)

if config.env_development
  app.use logger("dev", skip: (req, res) -> res.statusCode is 304)
  app.use assets_manager({"paths": config.assets}, register_mincer_engines)

if config.env_production
  log = fs.createWriteStream config.log_file, {flags: 'w'}
  app.use logger("combined", stream: log)
  app.use assets_manager({
    buildDir:       config.assets_build_dir,
    paths:          config.assets,
    compress:       true,
    fingerprinting: true
  }, register_mincer_engines)

app.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept'
  next()

app.use '/', pages_controller

if config.env_development
  app.use errorhandler()

app.use (req, res, next) ->
  res.status 404
  if req.accepts 'html'
    res.render 'errors/404'
    return
  if req.accepts 'json'
    res.send { error: 'Not found' }
    return

app.use (err, req, res, next) ->
  res.status 500
  res.render 'errors/500'

unless module.parent
  app.listen(config.port)
  console.log "Express server listening on port #{config.port} in '#{config.env}' environment"
