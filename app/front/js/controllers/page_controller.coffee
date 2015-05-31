Application.controller 'pageController', ['$scope', 'Theme', '$state', ($scope, Theme, $state) ->

  $scope.current_theme = Theme

  $scope.page_title = (theme) ->
    # TODO: use router custom data to set the title
    if $state.includes("editor.*")
      return 'TmTheme Editor' unless theme
      "#{theme.json.name} • TmTheme Editor"
    else
      "TmTheme Editor"

  return
]
