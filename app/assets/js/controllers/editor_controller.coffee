Angie.controller "editorController", ['$scope'], ($scope) ->

  FsInitHandler = (fs) ->
    $scope.fs = fs
    $scope.$apply()
    if $scope.last_cached_theme
      $scope.files.push($scope.last_cached_theme)
      fs.root.getFile $scope.last_cached_theme, {}, ((fileEntry) ->
        fileEntry.file ((file) ->
          reader = new FileReader()
          reader.onloadend = (e) ->
            $scope.xmlTheme  = this.result.trim()
            #console.log "XML:", $scope.xmlTheme
            $scope.jsonTheme = plist_to_json($scope.xmlTheme)
            #console.log "JSON:", $scope.jsonTheme
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
  window.BlobBuilder        = window.BlobBuilder || window.WebKitBlobBuilder
  window.requestFileSystem(window.TEMPORARY, 3*1024*1024,  FsInitHandler, FsErrorHandler)

  $scope.last_cached_theme = $.cookie('last_theme')
  $scope.fs = null
  $scope.xmlTheme = ""
  $scope.jsonTheme = ""
  $scope.files = []
  $scope.gcolors = []

  $scope.$watch "xmlTheme", (n,o) ->
    $scope.gcolors = []
    if $scope.jsonTheme && $scope.jsonTheme.settings
      for key, val of $scope.jsonTheme.settings[0].settings
        $scope.gcolors.push({"name": key, "color": val})

  $scope.bg = -> $scope.gcolors.length > 0 && $scope.gcolors.find((gc)-> gc.name == "background").color
  $scope.fg = -> $scope.gcolors.length > 0 && $scope.gcolors.find((gc)-> gc.name == "foreground").color

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

  $scope.has_color = (color) ->
    if $scope.get_color(color)
      "has_color"
    else
      false

  $scope.is = (fontStyle, rule) ->
    fs_array = rule.settings?.fontStyle?.split(" ") || []
    fs_array.any(fontStyle)

  $scope.toggle = (fontStyle, rule) ->
    rule.settings = {} unless rule.settings
    rule.settings.fontStyle = "" unless rule.settings.fontStyle
    if $scope.is(fontStyle, rule)
      rule.settings.fontStyle = rule.settings.fontStyle.split(" ").remove(fontStyle).join(" ")
    else
      rule.settings.fontStyle += " #{fontStyle}"

  $scope.setFiles = (element) ->
    $scope.files.push(file) for file in element.files
    for file in $scope.files
      #continue unless f.type.match("image.*")
      reader = new FileReader()
      reader.readAsText(file) # Read in the tmtheme file
      reader.onload = do (file) ->
        (e) ->
          $scope.xmlTheme = e.target.result.trim()
          $scope.fs && $scope.fs.root.getFile file.name, {create: true}, (fileEntry) ->
            fileEntry.createWriter (fileWriter) ->
              fileWriter.onwriteend = (e) ->
                $.cookie('last_theme', file.name)
                $scope.last_cached_theme = file.name
              blob = new Blob([e.target.result], {type: "text/plain"})
              fileWriter.write(blob)
          $scope.jsonTheme = plist_to_json(e.target.result)
          console.log $scope.jsonTheme
          $scope.$apply()

  $scope.download_theme = ->
    console.log json2plist($scope.jsonTheme)
    blob = new Blob([json2plist($scope.jsonTheme)], {type: "text/plain"})
    saveAs blob, $scope.last_cached_theme

  $scope.save_theme = ->
    $scope.fs && $scope.fs.root.getFile $scope.files.first(), {}, (fileEntry) ->
      fileEntry.createWriter (fileWriter) ->
        fileWriter.onwriteend = (e) -> console.log "File Saved"
        fileWriter.onerror = (e) -> console.log "Error in writing"
        #console.log json2plist($scope.jsonTheme)
        blob = new Blob([json2plist($scope.jsonTheme)], {type: "text/plain"})
        fileWriter.write(blob)

  $scope.styles = ->
    styles = ""
    if $scope.jsonTheme && $scope.jsonTheme.settings
      for rule in $scope.jsonTheme.settings
        fg_color  = if rule.settings.foreground then $scope.get_color(rule.settings.foreground) else null
        bg_color  = if rule.settings.background then $scope.get_color(rule.settings.background) else null
        bold      = $scope.is("bold", rule)
        italic    = $scope.is("italic", rule)
        underline = $scope.is("underline", rule)
        if rule.scope
          rules = rule.scope.split(",").map (r) -> ".#{r.trim()}"
          rules.each (r) ->
            styles += "#{r}{"
            styles += "color:#{fg_color};" if fg_color
            styles += "background-color:#{bg_color};" if bg_color
            styles += "font-weight:bold;" if bold
            styles += "font-style:italic;" if italic
            styles += "text-decoration:underline;" if underline
            styles += "}"
    #console.log styles
    styles

  $scope.border_color = (bgcolor) ->
    if $scope.light_or_dark(bgcolor) == "light" then "rgba(0,0,0,.33)" else "rgba(255,255,255,.33)"

  $scope.light_or_dark = (bgcolor) ->
    #console.log bgcolor
    c = tinycolor(bgcolor)
    #console.log c
    d = c.toRgb()
    #console.log d
    yiq = ((d.r*299)+(d.g*587)+(d.b*114))/1000
    if yiq >= 128 then "light" else "dark"

  $scope.darken = (color, percent) ->
    c = tinycolor(color)
    hsl = c.toHsl()
    hsl.l -= percent/100
    hsl.l = clamp(hsl.l)
    tinycolor(hsl).toHslString()

  $scope.lighten = (color, percent) ->
    c = tinycolor(color)
    hsl = c.toHsl()
    hsl.l += percent/100
    hsl.l = clamp(hsl.l)
    tinycolor(hsl).toHslString()

  clamp = (val) -> Math.min(1, Math.max(0, val))

  $scope.gutter = ->
    style = ""
    if $scope.jsonTheme && $scope.jsonTheme.settings && $scope.bg()
      bgcolor = $scope.get_color($scope.bg())
      if $scope.light_or_dark(bgcolor) == "light"
        style = "pre .l:before { background-color: #{$scope.darken(bgcolor, 2)};"
        style += "color: #{$scope.darken(bgcolor, 18)}};"
      else
        style = "pre .l:before { background-color: #{$scope.lighten(bgcolor, 2)};"
        style += "color: #{$scope.lighten(bgcolor, 12)}};"
    style

  $scope.selected_rule = null
  $scope.edit_popover_visible = false
  $scope.new_popover_visible = false
  $scope.popover_rule = {}
  $scope.new_rule_pristine = {"name":"","scope":"","settings":{}}
  $scope.new_rule = Object.clone($scope.new_rule_pristine)

  $scope.is_selected = (rule) ->
    rule == $scope.selected_rule

  $scope.selected_gradient = (rule) ->
    return "" unless $scope.is_selected(rule)
    if $scope.light_or_dark($scope.bg()) == "light" then "selected_bglight" else "selected_bgdark"

  $scope.mark_as_selected = (rule) ->
    $scope.selected_rule = rule
    $scope.edit_popover_visible = false

  $scope.toggle_edit_popover = (rule, rule_index) ->
    $scope.popover_rule = rule
    $scope.edit_popover_visible = true
    row = $("#scope-lists .rule-#{rule_index}")
    #console.log  row.offset().top + (row.outerHeight()/2)
    $("#edit-popover").css("top", row.offset().top + (row.outerHeight()/2) - 140)

  $scope.close_popover = ->
    $scope.edit_popover_visible = false

  $scope.$watch "edit_popover_visible", (n,o) ->
    if n
      $(".sidebar").css("overflow-y", "hidden")
    else
      $(".sidebar").css("overflow-y", "scroll")

  $scope.delete_rule = (rule) ->
    return if rule
    rules = $scope.jsonTheme.settings
    index = rules.findIndex(rule)
    rules.remove(rule)
    $scope.selected_rule = rules[index]
    $scope.edit_popover_visible = false

  $scope.toggle_new_rule_popover = ->
    $scope.new_rule = Object.clone($scope.new_rule_pristine, true)
    $scope.new_popover_visible = !$scope.new_popover_visible

  $scope.add_rule = (new_rule) ->
    $scope.jsonTheme.settings.push(new_rule)
    $scope.toggle_new_rule_popover()
    sidebar = $(".sidebar")
    max_scroll_height = sidebar[0].scrollHeight
    sidebar.animate {"scrollTop": max_scroll_height}, 500, "swing"