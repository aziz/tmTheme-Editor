angular.module("ui.config", []).value "ui.config", {}
angular.module "ui.filters", ["ui.config"]
angular.module "ui.directives", ["ui.config"]
angular.module "ui", ["ui.filters", "ui.directives", "ui.config"]

window.Angular = angular.module('ThemeEditor', ['ui'])
window.Application = {
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