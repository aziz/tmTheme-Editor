
window.Application = angular.module('ThemeEditor', ['ngSanitize', 'ui.sortable', 'ui.bootstrap'])

Application.run () ->
  $("#loading").remove() unless window.chrome
  enable_trasition = -> $('body').removeClass('transition-off')
  setTimeout(enable_trasition, 600)

# Function.extend
#   monitor: (self) ->
#     origFn = this
#     self = self || this
#     cFn = ->
#       cFn.calls_counter += 1
#       t0 = performance.now()
#       res = origFn.apply(self, arguments)
#       t1 = performance.now()
#       cFn.last_call_time += t1 - t0
#       res
#     cFn.calls_counter = 0
#     cFn.last_call_time = 0
#     return cFn

# use case of monitor is a controller

# for own k,v of $scope
#   if k[0] != "$" and angular.isFunction(v)
#     $scope[k] = v.monitor($scope)
# $scope.$report = ->
#   table = for own k,v of $scope
#     if k[0] != "$" and angular.isFunction(v)
#       { name: k, calls: v.calls_counter, time: v.last_call_time }
#   console.table table
