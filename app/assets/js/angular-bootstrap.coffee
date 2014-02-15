angular.module("ui.config", []).value "ui.config", {}
angular.module "ui.filters", ["ui.config"]
angular.module "ui.directives", ["ui.config"]
angular.module "ui", ["ui.filters", "ui.directives", "ui.config"]

window.app_module = angular.module('ThemeEditor', ['ngSanitize', 'ui'])
window.Application = {
  controller: (name, dependencies, fn) ->
    args = dependencies
    args.push(fn)
    app_module.controller name, args

  factory: (name, dependencies, fn) ->
    args = dependencies
    args.push(fn)
    app_module.factory name, args

  service: (name, dependencies, fn) ->
    args = dependencies
    args.push(fn)
    app_module.service name, args

  directive: (name, dependencies, fn) ->
    args = dependencies
    args.push(fn)
    app_module.directive name, args

  value: (name, val) -> app_module.value name, val
}
