Application.controller 'galleryController',
['$scope', '$location', 'Editor', 'ThemeLoader', 'Color', 'Theme', 'FileManager',
 ($scope,   $location,   Editor,   ThemeLoader,   Color,   Theme,  FileManager) ->

  $scope.Color = Color
  $scope.Theme = Theme
  $scope.FileManager = FileManager
  $scope.local_themes = []
  $scope.external_themes = []
  $scope.themes = []
  ThemeLoader.themes.then (data) -> $scope.themes = data

  $scope.gallery_filter = {name: ''}
  $scope.toggle_gallery_type_filter = (type) ->
    if $scope.gallery_filter.color_type == type
      delete $scope.gallery_filter.color_type
    else
      $scope.gallery_filter.color_type = type

  $scope.remove_local_theme = (theme) ->
    FileManager.remove(theme)
    $location.path('/') if $location.path() == "/editor/local/#{theme.name}"

  $scope.remove_external_theme = (theme) ->
    FileManager.remove_external_theme(theme)
    $location.path('/') if $location.path() == "/editor/url/#{theme.url}"

  #-----------------------------------------------------------------------
  $scope.$watchCollection 'Editor.current_theme', -> $scope.selected_theme = Editor.current_theme.name

  $scope.$watch 'FileManager.local_themes', (n, o) ->
    $scope.local_themes = n
  , true

  $scope.$watch 'FileManager.external_themes', (n, o) ->
    $scope.external_themes = n
  , true

  return
]
