Application.controller "galleryController", ['$scope', '$http', '$location', 'ThemeLoader', 'throbber'], ($scope, $http, $location, ThemeLoader, throbber) ->

  ThemeLoader.themes.success (data) ->
    for theme in data
      theme.type = if theme.light then "light" else "dark"
    $scope.themes = data

  $scope.selected_theme = null
  $scope.filter = {
    type: null
    name: null
  }

  $scope.load_theme = (theme) ->
    return if $scope.selected_theme == theme
    throbber.on()
    $("#edit-popover, #new-popover").hide()
    $scope.$parent.theme_type = ""
    $scope.$parent.scopes_filter.name = null
    $location.path(theme.name)
    $scope.selected_theme = theme
    ThemeLoader.load(theme).success (data) ->
      $scope.$parent.process_theme(data)
      throbber.off()

  $scope.is_selected_theme = (theme) -> theme == $scope.selected_theme

  $scope.toggle_type_filter = (type) ->
    if $scope.filter.type == type
      $scope.filter.type = null
    else
      $scope.filter.type = type