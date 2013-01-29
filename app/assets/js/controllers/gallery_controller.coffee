Angie.controller "galleryController", ['$scope', '$http'], ($scope, $http) ->
  $http.get("/gallery.json").success (data) ->
    #console.log data
    $scope.gallery = data

  $scope.selected_theme = null

  $scope.load_theme = (theme) ->
    $scope.selected_theme = theme
    #console.log theme.url
    $http.get("/get_uri?uri=#{encodeURIComponent(theme.url)}").success (data) ->
      #console.log data
      $scope.$parent.xmlTheme  = data
      $scope.$parent.jsonTheme = plist_to_json($scope.xmlTheme)
      # tmp = -> $scope.$apply()
      # setTimeout(100, tmp)

  $scope.is_selected_theme = (theme) -> theme == $scope.selected_theme
  $scope.selected_gradient = (theme) ->
    return "" unless $scope.is_selected_theme(theme)
    if $scope.light_or_dark($scope.bg()) == "light" then "selected_bglight" else "selected_bgdark"