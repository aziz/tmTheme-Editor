window.requestFileSystem  = window.requestFileSystem || window.webkitRequestFileSystem
window.BlobBuilder        = window.BlobBuilder || window.WebKitBlobBuilder
window.FsErrorHandler = (e) -> console.error "Error [#{e.name}] - #{e.message}"

window.app_module = angular.module('ThemeEditor', ['ngSanitize', 'ui.sortable', 'ui.bootstrap'])

# TODO: get rid of this layer of abstraction
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
