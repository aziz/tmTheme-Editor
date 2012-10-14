window.Angular = angular.module('ThemeEditor', [])

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
}