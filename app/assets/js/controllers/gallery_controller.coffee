Angie.controller "galleryController", ['$scope', '$http', '$location', 'ThemeLoader', 'throbber'], ($scope, $http, $location, ThemeLoader, throbber) ->

  ThemeLoader.themes.success (data) ->
    for theme in data
      theme.type = if theme.light then "light" else "dark"
    $scope.themes = data

  $scope.selected_theme = null

  $scope.load_theme = (theme) ->
    return if $scope.selected_theme == theme
    throbber.on()
    $("#edit-popover, #new-popover").hide()
    $location.path(theme.name)
    $scope.selected_theme = theme
    ThemeLoader.load(theme).success (data) ->
      $scope.$parent.xmlTheme  = data
      $scope.$parent.jsonTheme = plist_to_json($scope.xmlTheme)
      throbber.off()
      # console.log "THEME:", $scope.jsonTheme

  $scope.is_selected_theme = (theme) -> theme == $scope.selected_theme

  $scope.selected_gradient = (theme) ->
    return "" unless $scope.is_selected_theme(theme)
    if $scope.light_or_dark($scope.bg()) == "light" then "selected_bglight" else "selected_bgdark"

  $scope.filter = {
    type: null
    name: null
  }

  $scope.toggle_type_filter = (type) ->
    if $scope.filter.type == type
      $scope.filter.type = null
    else
      $scope.filter.type = type