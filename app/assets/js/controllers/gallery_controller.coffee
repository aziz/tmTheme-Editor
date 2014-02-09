Application.controller "galleryController", ['$scope', '$http', '$location', '$timeout', 'ThemeLoader', 'throbber'], ($scope, $http, $location, $timeout, ThemeLoader, throbber) ->

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
    $("#edit-popover, #new-popover").hide()
    $scope.$parent.theme_type = ""
    $scope.$parent.scopes_filter.name = null
    $location.search("local", null)
    $location.path("/theme/#{theme.name}")
    $scope.selected_theme = theme

  $scope.is_selected_theme = (theme) -> theme == $scope.selected_theme

  $scope.toggle_type_filter = (type) ->
    if $scope.filter.type == type
      $scope.filter.type = null
    else
      $scope.filter.type = type


  # -- Loading Local Files -------------------------------------------
  $scope.load_local_theme = (theme) ->
    return if $scope.selected_theme == theme
    throbber.on()
    $("#edit-popover, #new-popover").hide()
    $scope.$parent.theme_type = "Local File"
    $scope.$parent.scopes_filter.name = null
    $scope.selected_theme = theme
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
        console.log "File removed."
        $scope.localFiles.remove(theme)
        $scope.$apply()
      ), FsErrorHandler
    ), FsErrorHandler

  $scope.isThereLocalFiles = -> $scope.localFiles.length > 0
  $scope.localFiles = []
  toArray = (list) -> Array::slice.call list or [], 0
  list_local_files = ->
    dirReader = $scope.$parent.fs.root.createReader()
    # Call the reader.readEntries() until no more results are returned.
    readEntries = ->
      dirReader.readEntries ((results) ->
        if results.length
          $scope.localFiles = $scope.localFiles.concat(toArray(results))
          readEntries()
        else
          $scope.$apply()
      ), FsErrorHandler
    readEntries() # Start reading dirs.


  $timeout(list_local_files, 1000)
