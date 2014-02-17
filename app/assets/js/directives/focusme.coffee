Application.directive "focusMe", ['$timeout', ($timeout) ->
  link: (scope, element, attrs) ->
    scope.$watch attrs.focusMe, (value) ->
      return unless value
      set_focus = -> element[0].focus()
      $timeout(set_focus, 0)
      return
    return
]
