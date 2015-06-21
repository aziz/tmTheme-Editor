Application.factory "ScopeMatcher", ['Theme', (Theme) ->
  preview_root_scope = ->
    lang = $('#preview > pre').attr('class')
    root = ''
    root = lang.replace(/ng-\w+/g,'').trim().split(' ').join('.') if lang
    root

  element_scope = (scope, event, reverse=false) ->
    result = [scope]
    element = $(event.target)
    element.parents('s').each (index, item) ->
      result.push( $(item).data().entityScope )
      return

    if reverse
      lang = element.closest('span.l').attr('class')
      output = ''
      output += lang.replace(/l l-\d+\s/,'').trim().split(' ').join('.') + ' ' if lang
      output += result.reverse().join(' ')
      return output
    else
      result.join(' ')

  bestMachingThemeRule = (active_scope) ->
    return unless Theme.json.settings
    bestMatch = 0
    candidates = Theme.json.settings.findAll (item) ->
      return false unless item.scope
      item_scopes = item.scope.split(',').map((s) -> s.trim())
      match = item_scopes.filter (item_scope) ->
        item_scopes_arr = item_scope.split('.')
        active_scope_arr = active_scope.split('.')
        isMatching =  (item_scopes_arr.subtract(active_scope_arr)).length == 0
        bestMatch = item_scopes_arr.length if isMatching && item_scopes_arr.length > bestMatch
        return isMatching && item_scopes_arr.length >= bestMatch
      return item if match.length
    candidates.last()

  {
    element_scope
    preview_root_scope
    bestMachingThemeRule
  }
]
