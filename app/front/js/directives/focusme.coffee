Application.directive "focusMe", ['$timeout', ($timeout) ->
  link: (scope, element, attrs) ->
    scope.$watch attrs.focusMe, (value) ->
      return unless value
      set_focus = ->
        el = element[0]
        el.focus()
        el.select() if attrs.autoSelect == "true"
        return
      $timeout(set_focus, 0)
      return
    return
]
