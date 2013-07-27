Application.directive "draggable", ['$timeout'], ($timeout) ->
  restrict: "A"
  link: ($scope, element, attrs, controller) ->
    draggable = ->
      options = $scope.$eval(attrs.draggable) || {}
      element.draggable(options)
    $timeout draggable, 0, false

    $scope.$on 'CanvasLockChanged', (event, data) ->
      if data.lock
        element.draggable('destroy')
      else
        draggable()