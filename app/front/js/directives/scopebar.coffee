Application.directive 'scopeBar', ['ScopeMatcher', '$timeout', (ScopeMatcher, $timeout) ->
  replace: true
  templateUrl: 'template/scope_hunter/scope_hunter.html'
  link: ($scope, element, attr) ->
    preview_el = $('#preview')

    $scope.scroll_rule_into_view = (rule) ->
      $scope.Editor.Sidebar.current_tab = 'scopes'
      $scope.Editor.ScopeHunter.hovered_rule = rule
      scroll_finished = ->
        $timeout(->
          $scope.$apply -> $scope.Editor.ScopeHunter.hovered_rule = {}
          return
        , 2000)
      scroll_into_view = ->
        $('.hovered').scrollintoview(duration: 400, direction: 'vertical')
        scroll_finished()
        return
      $timeout scroll_into_view
      return

    mousemove = (event) ->
      entityScope = event.target.dataset.entityScope
      $scope.$apply ->
        if entityScope
          final_element_scope = ScopeMatcher.element_scope(entityScope, event)
          active_scope_rule = ScopeMatcher.bestMachingThemeRule(final_element_scope)
          hovered_element_scope = ScopeMatcher.element_scope(entityScope, event, true)
        else
          active_scope_rule = {}
          hovered_element_scope = ScopeMatcher.preview_root_scope()
        $scope.$parent.hovered_element_scope = hovered_element_scope
        $scope.$parent.hovered_rule = active_scope_rule

    preview_el.bind 'mousemove', mousemove

    preview_el.bind 'click', (event) ->
      entityScope = event.target.dataset.entityScope
      element = $(event.target)
      if entityScope
        if element.hasClass('hunted')
          preview_el.bind 'mousemove', mousemove
          element.removeClass 'hunted'
        else
          mousemove(event)
          preview_el.find('.hunted').removeClass('hunted')
          preview_el.unbind 'mousemove'
          element.addClass 'hunted'

    $scope.$on '$destroy', ->
      preview_el.find('.hunted').removeClass('hunted')
      preview_el.unbind 'mousemove'
      preview_el.unbind 'click'

    return
]
