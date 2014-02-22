Application.directive "draggable", ['$timeout', ($timeout) ->
  restrict: "A"
  link: (scope, element, attrs) ->
    draggable = ->
      options = scope.$eval(attrs.draggable) || {}
      element.draggable(options)
    $timeout draggable, 0, false
]
