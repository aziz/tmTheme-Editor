Angie.controller "StatsController", ['$scope', '$http', '$location', 'ThemeLoader'], ($scope, $http, $location, ThemeLoader) ->

  $scope.themes = []
  $scope.scopes_data = []
  $scope.progress = 0
  $scope.predicate = "name"
  $scope.reverse = false
  progress_unit = 0

  load_theme = (theme) ->
    ThemeLoader.load(theme).success (theme_data) ->
      theme.xmlTheme  = theme_data
      theme.jsonTheme = plist_to_json(theme.xmlTheme)
      theme.bgcolor = theme.jsonTheme.settings.first().settings.background
      theme.is_light = light_or_dark(theme.bgcolor.to(7)) == "light"
      process_scopes(theme.jsonTheme.settings)
      $scope.progress += progress_unit

  process_scopes = (settings) ->
    for setting in settings
      if setting.scope
        scopes = setting.scope.split(",").map((s) -> s.trim())
        for scope in scopes
          found_object = $scope.scopes_data.find((x) -> x.name == scope)
          if found_object
            found_object.count = found_object.count + 1
          else
            $scope.scopes_data.push({ "name": scope, "count" : 1})

  light_or_dark = (bgcolor) ->
    c = tinycolor(bgcolor)
    d = c.toRgb()
    yiq = ((d.r*299)+(d.g*587)+(d.b*114))/1000
    if yiq >= 128 then "light" else "dark"

  ThemeLoader.themes.success (data) ->
    $scope.themes = data
    progress_unit = 100.0/data.length
    load_theme(theme) for theme in $scope.themes

  $scope.gallery = ->
    $scope.themes.map (theme) ->
      {
        "name": theme.name
        "url": theme.url
        "light": theme.is_light
      }