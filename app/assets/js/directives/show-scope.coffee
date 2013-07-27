Application.directive "scopeBar", [], ->
  replace: true
  templateUrl: 'partials/scope_bar'

  link: (scope, element, attr) ->
    preview = element.prev()
    preview.bind "mouseover", (event) ->
      active = {}
      active.scope = event.target.dataset.entityScope

      if active.scope
        active_scope_rule = getScopeSettings(active.scope)
        active.name = active_scope_rule.name if active_scope_rule

      scope.$apply ->
        # Highlight in sidebar
        scope.$parent.hovered_rule = active_scope_rule

    preview.bind "mouseout", (event) ->
      # Unhighlight in sidebar
      scope.$parent.hovered_rule = null

    preview.bind "dblclick", (event) ->
      active = {}
      active.scope = event.target.dataset.entityScope

      if active.scope
        active_scope_rule = getScopeSettings(active.scope)
        showPopover active_scope_rule, event



    showPopover = (rule, event) ->
      scope.$apply ->
        scope.$parent.new_popover_visible = false
        scope.$parent.popover_rule = rule
        scope.$parent.edit_popover_visible = true

      popover = $("#edit-popover")

      if popover.is('.slide')
        left_offset = $("#gallery").width()
      else
        left_offset = 0

      offset =
        left: (popover.width() / 2) + 10 + left_offset
        top: 24

      popover.css({
        "left": event.pageX - offset.left
        "top": event.pageY + offset.top
      }).addClass("on-bottom")


    getScopeSettings = (active_scope) ->
      return unless scope.$parent.jsonTheme.settings

      return scope.$parent.jsonTheme.settings.find (item) ->
        return unless item.scope

        item_scopes = item.scope.split(', ')

        match = item_scopes.filter (item_scope) ->
          item_scopes_arr = item_scope.split('.')
          active_scope_arr = active_scope.split('.')

          return (item_scopes_arr.subtract active_scope_arr).length < 1

        return item if match.length
