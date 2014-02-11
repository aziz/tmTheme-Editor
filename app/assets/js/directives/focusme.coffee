Application.directive "focusMe", ['$timeout'], ($timeout) ->
  link: (scope, element, attrs) ->
    scope.$watch attrs.focusMe, (value) ->
      if value is true
        # console.log "value=", value
        $timeout( ->
          element[0].focus()
        , 0)
