Application.directive "scopeBar", ['$timeout', 'Theme', ($timeout, Theme) ->
  replace: true
  template: """
  <div ng-cloak ng-class="{ 'slide' : Editor.Gallery.visible }" class="scope-bar">
    <div class="status-scope">
      <span ng-show="hovered_element_scope" class="f-scope type-entity">{{ hovered_element_scope }}</span>
      <span ng-show="hovered_rule.name" class="f-scope type-entity-text">({{ hovered_rule.name }})</span>
    </div>
  </div>
  """
  link: (scope, element, attr) ->
    preview_el = $("#preview")
    scroll_promise = null

    preview_el.bind "mouseover", (event) ->
      active = {}
      active.scope = event.target.dataset.entityScope

      if active.scope
        final_element_scope = generateElementScope(active.scope, event)
        active_scope_rule = findBestMachingThemeRule(final_element_scope)
        active.name = active_scope_rule.name if active_scope_rule

      scope.$apply ->
        # setting scope text on the scopebar
        scope.$parent.hovered_element_scope = generateElementScope(active.scope, event, true)
        # Highlight in sidebar
        scope.$parent.hovered_rule = active_scope_rule

      scroll_into_view = -> $(".hovered").scrollintoview({duration: 500, direction: "vertical", viewPadding: 10})
      scroll_promise = $timeout scroll_into_view, 500

    preview_el.bind "mouseout", (event) ->
      # Unhighlight in sidebar
      $timeout.cancel(scroll_promise)
      scope.$parent.hovered_rule = null

    preview_el.bind "dblclick", (event) ->
      active = {}
      active.scope = event.target.dataset.entityScope

      if active.scope
        final_element_scope = generateElementScope(active.scope, event)
        active_scope_rule = findBestMachingThemeRule(final_element_scope)
        showPopover active_scope_rule, event


    showPopover = (rule, event) ->
      scope.$apply ->
        scope.$parent.NewPopover.visible = false
        scope.$parent.EditPopover.rule = rule
        scope.$parent.EditPopover.visible = true

      win_height    = $(window).height()
      popover       = $("#edit-popover")
      galley_offset = if popover.is('.slide') then $("#gallery").width() else 0
      offset_left   = (popover.width() / 2) + 10 + galley_offset
      elm           = $(event.target)
      elm_offset    = elm.offset()

      if (win_height - elm_offset.top) < 360
        popover.css({
          "top": "auto"
          "left": elm_offset.left + (elm.outerWidth()/2)  - offset_left
          "bottom": win_height - elm_offset.top + 5
        }).removeClass("on-bottom").addClass("on-top")
      else
        popover.css({
          "left": elm_offset.left + (elm.outerWidth()/2) - offset_left
          "top": elm_offset.top + 30
          "bottom": "auto"
        }).removeClass("on-top").addClass("on-bottom")

    # TODO: refactor, this function should not be called twice!
    generateElementScope = (scope, event, reverse=false) ->
      result = [scope]
      $(event.target).parents("s").each((index, item) ->
        result.push( $(item).data().entityScope )
      )
      if reverse
        lang = $(event.target).closest("span.l").attr("class")
        output = ""
        output += lang.replace(/l l-\d+\s/,"").trim().split(" ").join(".") + " " if lang
        output += result.reverse().join(" ")
        return output
      else
        result.join(" ")

    # Finds the best matching rule from theme, given the current scope
    findBestMachingThemeRule = (active_scope) ->
      return unless Theme.json.settings
      bestMatch = 0
      candidates = Theme.json.settings.findAll (item) ->
        return unless item.scope
        item_scopes = item.scope.split(',').map((s) -> s.trim())
        match = item_scopes.filter (item_scope) ->
          item_scopes_arr = item_scope.split('.')
          active_scope_arr = active_scope.split('.')
          isMatching =  (item_scopes_arr.subtract active_scope_arr).length < 1
          bestMatch = item_scopes_arr.length if isMatching && item_scopes_arr.length>bestMatch
          return isMatching && item_scopes_arr.length >= bestMatch

        return item if match.length

      candidates.last()

    return
]
