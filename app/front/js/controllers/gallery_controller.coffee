Application.controller 'galleryController',
['$scope', '$location', 'Editor', 'ThemeLoader', 'Color', 'Theme', 'FileManager',
 ($scope,   $location,   Editor,   ThemeLoader,   Color,   Theme,  FileManager) ->

  $scope.Color = Color
  $scope.Theme = Theme

  $scope.gallery_filter = {name: ''}
  $scope.toggle_gallery_type_filter = (type) ->
    if $scope.gallery_filter.color_type == type
      delete $scope.gallery_filter.color_type
    else
      $scope.gallery_filter.color_type = type

  $scope.$watchCollection 'Editor.current_theme', ->
    $scope.selected_theme = Editor.current_theme.name

  $scope.themes = []
  ThemeLoader.themes.then (data) -> $scope.themes = data

  $scope.local_themes    = FileManager.local_themes
  $scope.external_themes = FileManager.external_themes

  $scope.remove_local_theme = (theme) ->
    FileManager.remove(theme)
    $location.path('/') if $location.path() == "/local/#{theme.name}"

  # TODO: refactor, add remove external to file manager
  $scope.remove_external_theme = (theme) ->
    $scope.external_themes.remove(theme)
    localStorage.setItem('external_themes', angular.toJson($scope.external_themes))
    $location.path('/') if $location.path() == "/url/#{theme.url}"

]
