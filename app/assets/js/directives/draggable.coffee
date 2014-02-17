class InteractionHelper

  @normalisePoints = (event) ->
    event = if event.touches? then event.touches[0] else event

    event =
      pageX: event.pageX
      pageY: event.pageY

DragDirective = ($document) ->

  link: ($scope, $element, $attrs) ->
    endTypes = 'touchend touchcancel mouseup mouseleave'
    moveTypes = 'touchmove mousemove'
    startTypes = 'touchstart mousedown'

    moveTypesArray = moveTypes.split ' '

    $document.bind endTypes, (event) ->
      event.preventDefault()

      for type in moveTypesArray
        $document.unbind type

    $element.bind startTypes, (event) ->
      event.preventDefault()

      elementStartX = parseInt $element.css 'left'
      elementStartY = parseInt $element.css 'top'
      interactionStart = InteractionHelper.normalisePoints event

      if isNaN elementStartX
        elementStartRight = parseInt $element.css 'right'
        if isNaN elementStartRight
          elementStartX = 0
        else
          elementStartX = $(window).width() - elementStartRight - $element.outerWidth()

      if isNaN elementStartY
        elementStartY = 0

      $document.bind moveTypes, (event) ->
        event.preventDefault()

        interactionCurrent = InteractionHelper.normalisePoints event

        $element.css
          left: elementStartX + (interactionCurrent.pageX - interactionStart.pageX) + 'px'
          top: elementStartY + (interactionCurrent.pageY - interactionStart.pageY) + 'px'
          right: 'auto'


Application.directive 'draggable', ['$document'], DragDirective
