Application.controller 'pageController', ['$scope', 'Theme', ($scope, Theme) ->

  $scope.current_theme = Theme

  $scope.page_title = (theme) ->
    return 'TmTheme Editor' unless theme
    "#{theme.json.name} • TmTheme Editor"

  return
]
