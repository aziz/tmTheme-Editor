Angie.directive "shortcut", [], ()->
  (scope, element, attr) ->
    element.bind "keyup", (event) ->
      # console.log attr.shortcut
      # console.log event.keyCode
      # console.log event
      # console.log String.fromCharCode(event.keyCode).toLowerCase()
      shortcut_obj = JSON.parse(attr.shortcut)
      switch
        when event.keyCode == 27
          scope.$apply shortcut_obj["escape"]
        when 32 <= event.keyCode <= 126
          string = String.fromCharCode(event.keyCode).toLowerCase()
          string = "ctrl+#{string}" if event.ctrlKey
          scope.$apply shortcut_obj[string]
        # else
        #   console.log "no match"
