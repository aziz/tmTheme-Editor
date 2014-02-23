
window.Application = angular.module('ThemeEditor', ['ngSanitize', 'ui.sortable', 'ui.bootstrap'])

Application.run ["$rootScope", ($rootScope) ->

  # $rootScope.is_browser_supported = if window.chrome then true else false
  $rootScope.is_browser_supported = true

  enable_trasition = -> $('body').removeClass('transition-off')
  setTimeout(enable_trasition, 600)
]

# Function.extend
#   monitor: (self) ->
#     origFn = this
#     self = self || this
#     decoratedFn = ->
#       decoratedFn.calls_counter += 1
#       t0 = performance.now()
#       res = origFn.apply(self, arguments)
#       t1 = performance.now()
#       decoratedFn.last_call_time += t1 - t0
#       res
#     decoratedFn.calls_counter = 0
#     decoratedFn.last_call_time = 0
#     decoratedFn.toString = -> origFn.toString()
#     return decoratedFn

# use case of monitor is a controller

# for own k,v of $scope
#   if k[0] != "$" and angular.isFunction(v)
#     $scope[k] = v.monitor($scope)
# $scope.$report = ->
#   table = for own k,v of $scope
#     if k[0] != "$" and angular.isFunction(v)
#       { name: k, calls: v.calls_counter, time: v.last_call_time }
#   console.table table
