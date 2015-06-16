Application.controller 'galleryController',
['$scope', '$location', '$filter', 'Editor', 'ThemeLoader', 'Color', 'Theme', 'FileManager',
 ($scope,   $location,   $filter,   Editor,   ThemeLoader,   Color,   Theme,   FileManager) ->

  $scope.Color = Color
  $scope.Theme = Theme
  $scope.FileManager = FileManager
  $scope.local_themes = []
  $scope.external_themes = []
  $scope.themes = []
  $scope.filtered_gallery = []
  ThemeLoader.themes.then (data) ->
    $scope.themes_data = data
    render_theme_list(data)

  render_theme_list = (data) ->
    return unless data
    $scope.filtered_gallery = data
    themes_html = ""
    selected = Editor.current_theme.name
    for theme in data
      themes_html += """
      <li #{if theme.name == selected then 'class="selected"' else ''}>
        <a href="/#!/editor/theme/#{theme.name}">
          <span class="#{theme.color_type}_theme_icon"></span>
          <span>#{theme.name}</span>
        </a>
      </li>
      """
    $scope.themes = themes_html


  $scope.gallery_filter = {name: ''}
  $scope.toggle_gallery_type_filter = (type) ->
    if $scope.gallery_filter.color_type == type
      delete $scope.gallery_filter.color_type
    else
      $scope.gallery_filter.color_type = type

  $scope.$watch 'gallery_filter', (n, o) ->
    return unless n
    data = $filter('filter')($scope.themes_data, $scope.gallery_filter)
    render_theme_list(data)
  , true

  $scope.remove_local_theme = (theme) ->
    FileManager.remove(theme)
    $location.path('/') if $location.path() == "/editor/local/#{theme.name}"

  $scope.remove_external_theme = (theme) ->
    FileManager.remove_external_theme(theme)
    $location.path('/') if $location.path() == "/editor/url/#{theme.url}"

  #-----------------------------------------------------------------------
  $scope.$watchCollection 'Editor.current_theme', ->
    $scope.selected_theme = Editor.current_theme.name
    render_theme_list($scope.themes_data)

  $scope.$watch 'FileManager.local_themes', (n, o) ->
    $scope.local_themes = n
  , true

  $scope.$watch 'FileManager.external_themes', (n, o) ->
    $scope.external_themes = n
  , true

  return
]
