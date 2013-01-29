Angie.controller "galleryController", ['$scope', '$http', '$location', 'ThemeLoader'], ($scope, $http, $location, ThemeLoader) ->

  ThemeLoader.themes.success (data) -> $scope.themes = data

  $scope.selected_theme = null

  $scope.load_theme = (theme) ->
    $location.path(theme.name)
    $scope.selected_theme = theme
    ThemeLoader.load(theme).success (data) ->
      $scope.$parent.xmlTheme  = data
      $scope.$parent.jsonTheme = plist_to_json($scope.xmlTheme)
      console.log "THEME:", $scope.jsonTheme
      # tmp = -> $scope.$apply()
      # setTimeout(100, tmp)

  $scope.is_selected_theme = (theme) -> theme == $scope.selected_theme

  $scope.selected_gradient = (theme) ->
    return "" unless $scope.is_selected_theme(theme)
    if $scope.light_or_dark($scope.bg()) == "light" then "selected_bglight" else "selected_bgdark"