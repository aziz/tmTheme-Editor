Application.controller "galleryController", ['$scope', '$http', '$location', '$timeout', 'ThemeLoader', 'throbber'], ($scope, $http, $location, $timeout, ThemeLoader, throbber) ->

  ThemeLoader.themes.success (data) ->
    for theme in data
      theme.type = if theme.light then "light" else "dark"
    $scope.themes = data

  $scope.filter = {name: ""}

  $scope.load_theme = (theme) ->
    return if $scope.selected_theme == theme
    $scope.$parent.new_popover_visible = false
    $scope.$parent.edit_popover_visible = false
    $scope.$parent.theme_type = ""
    $scope.$parent.scopes_filter.name = ''
    $location.search("local", null)
    $location.path("/theme/#{theme.name}")
    $scope.$parent.selected_theme = theme

  $scope.toggle_type_filter = (type) ->
    if $scope.filter.type == type
      $scope.filter.type = undefined
    else
      $scope.filter.type = type

  # -- Loading Local Files -------------------------------------------
  $scope.load_local_theme = (theme) ->
    return if $scope.selected_theme == theme
    throbber.on()
    $("#edit-popover, #new-popover").hide()
    $scope.$parent.theme_type = "Local File"
    $scope.$parent.scopes_filter.name = ''
    $scope.$parent.selected_theme = theme
    $scope.$parent.files.push(theme.name)
    $scope.$parent.fs.root.getFile theme.name, {}, ((fileEntry) ->
      fileEntry.file ((file) ->
        reader = new FileReader()
        reader.onloadend = (e) ->
          $scope.$parent.process_theme(this.result.trim())
          $location.path("/local/#{theme.name}")
          $scope.$parent.$apply()
          throbber.off()
        reader.readAsText file
      ), FsErrorHandler
    ), FsErrorHandler

  $scope.remove_local_theme = (theme) ->
    $scope.$parent.fs.root.getFile theme.name, {create: false}, ((fileEntry) ->
      fileEntry.remove (->
        # console.log "File removed."
        $scope.localFiles.remove(theme)
        if $location.path() == "/local/#{theme.name}"
          # console.log "removing deleted theme from path"
          $location.path("/")
        $scope.$apply()
      ), FsErrorHandler
    ), FsErrorHandler
