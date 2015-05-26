Application.controller 'StatsController',
['Color', 'ThemeLoader', 'plist_to_json', '$scope', '$http', '$location',
( Color,   ThemeLoader ,  plist_to_json,   $scope,   $http,   $location) ->

  $scope.themes = []
  $scope.scopes_data = []
  $scope.general_data = []
  $scope.progress = 0
  $scope.predicate = 'name'
  $scope.reverse = false

  $scope.scopes_predicate = 'count'
  $scope.scopes_reverse = true

  $scope.current_tab = 'themes'
  progress_unit = 0

  load_theme = (theme) ->

    process_theme = (theme_data) ->
      theme.xmlTheme  = theme_data
      theme.jsonTheme = plist_to_json(theme.xmlTheme)
      theme.bgcolor = theme.jsonTheme.settings.first().settings.background
      console.log theme unless theme.bgcolor
      theme.is_light = Color.light_or_dark(theme.bgcolor[0..6]) == 'light'
      theme.general_settings_count = Object.extended(theme.jsonTheme.settings.first().settings).size()
      process = -> process_scopes(theme.jsonTheme.settings)
      setTimeout(process, 0)

    handle_load_error = ->

    theme_loader_promise = ThemeLoader.load(theme)
    theme_loader_promise.then(process_theme, handle_load_error)

  process_scopes = (settings) ->
    for key,value of settings[0].settings
      found_object = $scope.general_data.find((x) -> x.name == key)
      if found_object
        found_object.count = found_object.count + 1
      else
        $scope.general_data.push({ name: key, count: 1, values: [] })
      if key.endsWith('Options')
        current_object = $scope.general_data.find((x) -> x.name == key)
        current_object.values.push(value)

    for d in $scope.general_data
      d.grouped_values = d.values.groupBy()

    for setting in settings
      if setting.scope
        scopes = setting.scope.split(',').map((s) -> s.trim())
        for scope in scopes
          found_object = $scope.scopes_data.find((x) -> x.name == scope)
          if found_object
            found_object.count = found_object.count + 1
          else
            $scope.scopes_data.push({ name: scope, count: 1})
    $scope.update_progress()

  ThemeLoader.themes.then (data) ->
    $scope.themes = data
    progress_unit = 100.0/data.length
    for theme in $scope.themes
      load_theme(theme)

  $scope.update_progress = ->
    $scope.$apply ->
      $scope.progress += progress_unit

  $scope.gallery = ->
    $scope.themes.map (theme) ->
      {
        name: theme.name
        url: theme.url
        light: theme.is_light
      }

]
