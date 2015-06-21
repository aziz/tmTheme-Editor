Application.directive 'inlineEdit', ['ScopeMatcher', (ScopeMatcher) ->
  link: ($scope, element, attr) ->
    preview_el = $('#preview')

    preview_el.bind 'dblclick', (event) ->
      entityScope = event.target.dataset.entityScope
      if entityScope
        final_element_scope = ScopeMatcher.element_scope(entityScope, event)
        active_scope_rule = ScopeMatcher.bestMachingThemeRule(final_element_scope)
        showPopover(active_scope_rule, event)

    $scope.$on '$destroy', -> preview_el.unbind 'dblclick'

    showPopover = (rule, event) ->
      $scope.$apply ->
        $scope.$parent.NewPopover.visible = false
        $scope.$parent.EditPopover.rule = rule
        $scope.$parent.EditPopover.visible = true

      win_height    = $(window).height()
      popover       = $('#edit-popover')
      galley_offset = if popover.is('.slide') then $('#gallery').width() else 0
      offset_left   = (popover.width() / 2) + 10 + galley_offset
      elm           = $(event.target)
      elm_offset    = elm.offset()

      if (win_height - elm_offset.top) < 360
        popover.css({
          top: 'auto'
          left: elm_offset.left + (elm.outerWidth()/2)  - offset_left
          bottom: win_height - elm_offset.top + 5
        }).removeClass('on-bottom').addClass('on-top')
      else
        popover.css({
          left: elm_offset.left + (elm.outerWidth()/2) - offset_left
          top: elm_offset.top + 30
          bottom: 'auto'
        }).removeClass('on-top').addClass('on-bottom')

    return
]
