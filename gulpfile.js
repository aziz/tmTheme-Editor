var coffeescript = require('coffee-script/register');
var path   = require('path');
var Mincer = require('mincer');

var gulp        = require('gulp');
var clean       = require('gulp-clean');
var concat      = require('gulp-concat');
var ext_replace = require('gulp-ext-replace');
var cleaning    = require('gulp-initial-cleaning');
var minCSS      = require('gulp-minify-css');
var uglify      = require('gulp-uglify');
var remoteSrc   = require('gulp-remote-src');
var minifyHTML  = require('gulp-minify-html');
var mince       = require('gulp-mincer');

var environment = new Mincer.Environment();
var ngTemplatesEngine = require('./app/back/lib/ngtemplate.coffee');

var server;
var DIST_DIR = "dist";
var ASSETS_DIR = DIST_DIR + "/assets";
var ASSETS_PATH = ["app/front/js", "app/front/css", "bower_components"];
var ASSETS = {
  external_scripts: "app/front/js/*.js",
  scripts:          "app/front/js/*.coffee",
  styles:           "app/front/css/*.less"
};

environment.registerEngine('.html',  ngTemplatesEngine);
environment.appendPath(ASSETS_PATH);

cleaning({tasks: ['default'], folders: ['dist']});

gulp.task('js-ext', function() {
  return gulp.src(ASSETS.external_scripts)
             .pipe(mince(environment))
             .pipe(uglify())
             .pipe(gulp.dest(ASSETS_DIR));
});

gulp.task('js', function() {
  return gulp.src(ASSETS.scripts)
             .pipe(mince(environment))
             .pipe(uglify())
             .pipe(ext_replace('.js'))
             .pipe(gulp.dest(ASSETS_DIR));
});

gulp.task('css', function() {
  return gulp.src(ASSETS.styles)
             .pipe(mince(environment))
             .pipe(minCSS())
             .pipe(ext_replace('.css'))
             .pipe(gulp.dest(ASSETS_DIR));
});

gulp.task('html', function() {
  process.env.NODE_ENV = 'production';
  var app = require('./app/back/app.coffee');
  server = app.listen(9898);
  var opts = {
     conditionals: true,
     spare: true,
     loose: true
  };
  return remoteSrc(['/'], { base: 'http://localhost:9898' })
    .pipe(concat('index.html'))
    .pipe(minifyHTML(opts))
    .pipe(gulp.dest(DIST_DIR));
});

gulp.task('static-assets', function() {
  gulp.src([
    'app/front/public/**',
    '!app/front/public/assets{,/**}'
  ]).pipe(gulp.dest(DIST_DIR));
});

gulp.task('default', ['js-ext', 'js', 'css', 'html', 'static-assets'], function() {
  var cleanups = ['app/front/public/assets', 'production.log'];
  gulp.src(cleanups, {read: false}).pipe(clean());
  server.close();
});
