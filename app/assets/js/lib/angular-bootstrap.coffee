angular.module("ui.config", []).value "ui.config", {}
angular.module "ui.filters", ["ui.config"]
angular.module "ui.directives", ["ui.config"]
angular.module "ui", ["ui.filters", "ui.directives", "ui.config"]

window.Angular = angular.module('ThemeEditor', ['ui'])

Angular.config(["$httpProvider", (provider) ->
  token = $('meta[name=csrf-token]').attr('content')
  provider.defaults.headers['post'] ||= {}
  provider.defaults.headers.post['X-CSRF-Token'] = token
  provider.defaults.headers['put'] ||= {}
  provider.defaults.headers.put['X-CSRF-Token'] = token
  provider.defaults.headers['delete'] ||= {}
  provider.defaults.headers.delete['X-CSRF-Token'] = token
])

window.Angie = {
  controller: (name, dependencies, fn) ->
    args = dependencies
    args.push(fn)
    Angular.controller name, args

  factory: (name, dependencies, fn) ->
    args = dependencies
    args.push(fn)
    Angular.factory name, args

  service: (name, dependencies, fn) ->
    args = dependencies
    args.push(fn)
    Angular.service name, args

  directive: (name, dependencies, fn) ->
    args = dependencies
    args.push(fn)
    Angular.directive name, args

}