var path     = require('path');
var Mincer   = require('mincer');
var gulp     = require('gulp');
var concat   = require('gulp-concat');
var coffee   = require('gulp-coffee');
var less     = require('gulp-less');
var minCSS   = require('gulp-minify-css');
var uglify   = require('gulp-uglify');

var DIST_DIR = "dist/";
var APP_ASSETS = ["app/front/js", "app/front/css", "bower_components"];

var environment = new Mincer.Environment();
environment.appendPath(APP_ASSETS);

var assets_path = {
  external_scripts: listAssetsIn("libs.coffee"),
  scripts:          listAssetsIn("application.coffee"),
  styles:           listAssetsIn("app.less"),
  templates:        'app/front/public/templates/**/*.html'
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
             .pipe(gulp.dest(DIST_DIR));
});


gulp.task('js', function() {
  return gulp.src(assets_path.scripts)
             .pipe(coffee({bare: true}))
             // .pipe(ngmin())
             .pipe(concat('app.js'))
             .pipe(uglify())
             .pipe(gulp.dest(DIST_DIR));
});

gulp.task('css', function() {
  console.log(assets_path.styles);
  return gulp.src(assets_path.styles)
             .pipe(less({paths: APP_ASSETS}))
             .pipe(concat('app.css'))
             .pipe(minCSS())
             .pipe(gulp.dest(DIST_DIR));
});


gulp.task('default', ['js-ext', 'js', 'css']);
