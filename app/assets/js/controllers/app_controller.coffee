Angie.controller "appController", ['$scope'], ($scope) ->

  FsInitHandler = (fs) ->
    $scope.fs = fs
    $scope.$apply()
    if $scope.last_cached_theme
      fs.root.getFile $scope.last_cached_theme, {}, ((fileEntry) ->
        fileEntry.file ((file) ->
          reader = new FileReader()
          reader.onloadend = (e) ->
            $scope.xmlTheme  = this.result
            $scope.jsonTheme = plist_to_json(this.result)
            console.log $scope.jsonTheme
            $scope.$apply()
          reader.readAsText file
        ), FsErrorHandler
      ), FsErrorHandler

  FsErrorHandler = (e) ->
    msg = ""
    switch e.code
      when FileError.QUOTA_EXCEEDED_ERR
        msg = "QUOTA_EXCEEDED_ERR"
      when FileError.NOT_FOUND_ERR
        msg = "NOT_FOUND_ERR"
      when FileError.SECURITY_ERR
        msg = "SECURITY_ERR"
      when FileError.INVALID_MODIFICATION_ERR
        msg = "INVALID_MODIFICATION_ERR"
      when FileError.INVALID_STATE_ERR
        msg = "INVALID_STATE_ERR"
      else
        msg = "Unknown Error"
    console.log "Error: " + msg

  window.requestFileSystem  = window.requestFileSystem || window.webkitRequestFileSystem
  window.BlobBuilder = window.BlobBuilder || window.WebKitBlobBuilder
  window.requestFileSystem(window.TEMPORARY, 3*1024*1024,  FsInitHandler, FsErrorHandler)

  $scope.last_cached_theme = $.cookie('last_theme')
  $scope.fs = null
  $scope.xmlTheme = ""
  $scope.jsonTheme = ""
  $scope.files = []

  $scope.get_color = (color) ->
    if color && color.length > 7
      hex_color = color.to(7)
      rgba = tinycolor(hex_color).toRgb()
      opacity = parseInt(color.at(7,8).join(""), 16)*(1/255)
      rgba.a = opacity
      new_rgba = tinycolor(rgba)
      new_rgba.toRgbString()
    else
      color

  $scope.is = (fontStyle, rule) ->
    fs_array = rule.settings?.fontStyle?.split(" ") || []
    fs_array.any(fontStyle)

  $scope.toggle = (fontStyle, rule) ->

  $scope.setFiles = (element) ->
    $scope.files.push(file) for file in element.files
    for file in $scope.files
      #continue unless f.type.match("image.*")
      reader = new FileReader()
      reader.readAsText(file) # Read in the tmtheme file
      reader.onload = do (file) ->
        (e) ->
          $scope.xmlTheme = e.target.result
          $scope.fs && $scope.fs.root.getFile file.name, {create: true}, (fileEntry) ->
            fileEntry.createWriter (fileWriter) ->
              fileWriter.onwriteend = (e) ->
                $.cookie('last_theme', file.name)
                $scope.last_cached_theme = file.name
              blob = new Blob([e.target.result], {type: "text/plain"})
              fileWriter.write(blob)
          $scope.jsonTheme = plist_to_json(e.target.result)
          if $scope.jsonTheme.settings?[0].settings?.selection
            $scope.jsonTheme.settings[0].name = "Default"
          console.log $scope.jsonTheme
          $scope.$apply()

  $scope.save_theme = ->
    blob = new Blob([json2plist($scope.jsonTheme)], {type: "text/plain;charset=utf-8"})
    saveAs blob, $scope.last_cached_theme

