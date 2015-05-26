config = module.exports = {}

config.assets = ['app/front/js', 'app/front/css', 'bower_components']
config.cookie_secret = 'sandbox secret string'
config.env = process.env.NODE_ENV || 'development'
config.port = process.env.PORT || 9999
config.env_development = true

# Production Specific
if config.env == 'production'
  config.port = process.env.PORT || 80
  config.env_development = false
  config.env_production = true
  config.log_file = 'production.log'
  config.assets_build_dir = process.env.ASSETS_BUILD_DIR || 'app/front/public/assets/'
