var coffeescript = require('coffee-script/register');

var path     = require('path');
var Mincer   = require('mincer');

var gulp       = require('gulp');
var concat     = require('gulp-concat');
var coffee     = require('gulp-coffee');
var less       = require('gulp-less');
var minCSS     = require('gulp-minify-css');
var uglify     = require('gulp-uglify');
var remoteSrc  = require('gulp-remote-src');
var cleaning   = require('gulp-initial-cleaning');
var clean      = require('gulp-clean');
var minifyHTML = require('gulp-minify-html');
var ngTmpl     = require('gulp-angular-templatecache');


var DIST_DIR = "dist";
var ASSETS_DIR = DIST_DIR + "/assets";
var APP_ASSETS = ["app/front/js", "app/front/css", "bower_components"];

var environment = new Mincer.Environment();
environment.appendPath(APP_ASSETS);

var assets_path = {
  external_scripts: listAssetsIn("libs.coffee"),
  scripts:          listAssetsIn("application.coffee"),
  styles:           listAssetsIn("app.less"),
  templates:        'app/front/public/template/**/*'
};

function listAssetsIn(asset_name) {
  var a, asset;
  asset = environment.findAsset(asset_name);
  return ((function() {
    var _i, _len, _ref, _results;
    _ref = asset.toArray();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      a = _ref[_i];
      _results.push("." + a.relativePath);
    }
    return _results;
  })()).slice(0, -1);
}

gulp.task('js-ext', function() {
  return gulp.src(assets_path.external_scripts)
             .pipe(concat('libs.js'))
             .pipe(uglify())
             .pipe(gulp.dest(ASSETS_DIR));
});

gulp.task('js', function() {
  return gulp.src(assets_path.scripts)
             .pipe(coffee({bare: true}))
             // .pipe(ngmin())
             .pipe(concat('application.js'))
             .pipe(uglify())
             .pipe(gulp.dest(ASSETS_DIR));
});

gulp.task('ng-templates', function () {
  return gulp.src(assets_path.templates)
             .pipe(ngTmpl({root: '/template/'}))
             .pipe(gulp.dest(ASSETS_DIR));
});

gulp.task('css', function() {
  // console.log(assets_path.styles);
  return gulp.src(assets_path.styles)
             .pipe(less({paths: APP_ASSETS}))
             .pipe(concat('app.css'))
             .pipe(minCSS())
             .pipe(gulp.dest(ASSETS_DIR));
});

var server;

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
    // .pipe(minifyHTML(opts))
    .pipe(gulp.dest(DIST_DIR));
});

gulp.task('static-assets', function() {
  gulp.src([
    'app/front/public/**',
    '!app/front/public/assets{,/**}'
    // , '!app/front/public/template{,/**}'
  ]).pipe(gulp.dest(DIST_DIR));
});

cleaning({tasks: ['default'], folders: ['dist/']});

gulp.task('default', ['js-ext', 'js', 'ng-templates', 'css', 'html', 'static-assets'], function() {
  var cleanups = ['app/front/public/assets'];
  gulp.src(cleanups, {read: false}).pipe(clean());
  server.close();
});
