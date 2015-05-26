Application.directive "shortcut", [ ->
  (scope, element, attr) ->
    element.bind "keyup", (event) ->
      shortcut_obj = scope.$eval(attr.shortcut)
      switch
        when event.keyCode == 27
          scope.$apply shortcut_obj["escape"]
        when event.keyCode == 13
          scope.$apply shortcut_obj["enter"]
        when 32 <= event.keyCode <= 126
          string = String.fromCharCode(event.keyCode).toLowerCase()
          string = "ctrl+#{string}" if event.ctrlKey
          scope.$apply shortcut_obj[string]
        # else
        #   console.log "no match"
]
