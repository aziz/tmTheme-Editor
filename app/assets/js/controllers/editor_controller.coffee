Angie.controller "editorController", ['$scope', '$http', '$location', 'ThemeLoader'], ($scope, $http, $location, ThemeLoader) ->

  $scope.is_browser_supported = window.chrome
  $scope.last_cached_theme = $.cookie('last_theme')
  $scope.fs = null

  $scope.current_tab   = 'scopes'
  $scope.scopes_filter = { name: null }
  $scope.xmlTheme = ""
  $scope.jsonTheme = ""
  $scope.files = []
  $scope.gcolors = []
  $scope.selected_rule = null
  $scope.popover_rule = {}
  $scope.edit_popover_visible = false
  $scope.new_popover_visible = false
  $scope.new_rule_pristine = {"name":"","scope":"","settings":{}}
  $scope.new_rule = Object.clone($scope.new_rule_pristine)
  $scope.gallery = if $.cookie('gallery_state') && $.cookie('gallery_state') == "slide" then "slide" else null
  $scope.new_property = {property: "", value: ""}

  $scope.sortable_options = {
    axis: "y"
    containment: "parent"
    helper: (e, tr) ->
      originals = tr.children()
      helper = tr.clone()
      helper.children().each (index) ->
        $(this).width originals.eq(index).width()
      helper
  }

  $scope.shortcuts = {
    "escape": "hide_all_popovers()",
    "ctrl+n": "toggle_new_rule_popover()"
  }

  $scope.page_title = ->
    if $scope.jsonTheme
      $scope.jsonTheme.name + ' — ' + 'TmTheme Editor'
    else
      'TmTheme Editor'

  $scope.toggle_gallery = ->
    if $scope.gallery
      $scope.gallery = null
      $.cookie('gallery_state', "closed")
    else
      $scope.gallery = "slide"
      $.cookie('gallery_state', "slide")

  clamp = (val) -> Math.min(1, Math.max(0, val))

  # -- Initializing ----------------------------------------------

  # There's theme name in URL
  if $location.path() && $location.path().replace("/","").length > 0
    theme = $location.path().replace("/","")
  # There's a theme locally saved
  else if $scope.last_cached_theme
    console.log "Loading from local file system"
  # Loading Default theme
  else
    theme = "PlasticCodeWrap"
    $location.path("PlasticCodeWrap")
  ThemeLoader.themes.success (data) ->
    available_themes = data
    if theme
      theme_obj = available_themes.find (t) -> t.name == theme
      ThemeLoader.load(theme_obj).success (data) -> $scope.process_theme(data)

  $scope.process_theme = (data) ->
    $scope.xmlTheme  = data
    $scope.jsonTheme = plist_to_json(data)
    $scope.gcolors = []
    $scope.selected_rule = null
    if $scope.jsonTheme && $scope.jsonTheme.settings
      for key, val of $scope.jsonTheme.settings[0].settings
        $scope.gcolors.push({"name": key, "color": val})
      $scope.jsonTheme.colorSpaceName = "sRGB"
      $scope.jsonTheme.semanticClass = "theme.#{$scope.light_or_dark($scope.bg())}.#{$scope.jsonTheme.name.underscore().replace(/[\(\)'&]/g, "")}"


  # File System API -----------------------------------------
  FsInitHandler = (fs) ->
    $scope.fs = fs
    $scope.$apply()

    if $scope.last_cached_theme && !($location.path() && $location.path().replace("/","").length > 0)
      $scope.files.push($scope.last_cached_theme)
      fs.root.getFile $scope.last_cached_theme, {}, ((fileEntry) ->
        fileEntry.file ((file) ->
          reader = new FileReader()
          reader.onloadend = (e) ->
            $scope.process_theme(this.result.trim())
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

  read_files = (files) ->
    for file in files
      #continue unless f.type.match("tmtheme")
      reader = new FileReader()
      reader.readAsText(file) # Read in the tmtheme file
      reader.onload = do (file) ->
        (e) ->
          xml_data = e.target.result.trim()
          $scope.fs && $scope.fs.root.getFile file.name, {create: true}, (fileEntry) ->
            fileEntry.createWriter (fileWriter) ->
              fileWriter.onwriteend = (e) ->
                $.cookie('last_theme', file.name)
                $scope.last_cached_theme = file.name
              blob = new Blob([xml_data], {type: "text/plain"})
              fileWriter.write(blob)
          $scope.process_theme(xml_data)
          $location.path("")
          $scope.$apply()

  $scope.setFiles = (element) ->
    $scope.files.push(file) for file in element.files
    read_files($scope.files)

  # Drag & Drop ---------------------------------------------
  dropZone = document.getElementById('drop_zone')

  handleFileDrop = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    files = evt.dataTransfer.files # FileList object.
    $scope.files.push(file.name) for file in files
    read_files(files)

  handleDragOver = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    evt.dataTransfer.dropEffect = "copy"

  dropZone.addEventListener 'dragover', handleDragOver, false
  dropZone.addEventListener 'drop', handleFileDrop, false


  # COLOR ----------------------------------------------------

  $scope.bg = -> $scope.gcolors.length > 0 && $scope.gcolors.find((gc)-> gc.name == "background").color
  $scope.fg = -> $scope.gcolors.length > 0 && $scope.gcolors.find((gc)-> gc.name == "foreground").color
  $scope.selection_color = -> $scope.gcolors.length > 0 && $scope.gcolors.find((gc)-> gc.name == "selection")?.color
  $scope.gutter_fg = -> $scope.gcolors.length > 0 && $scope.gcolors.find((gc)-> gc.name == "gutterForeground")?.color

  $scope.get_color = (color) ->
    if color && color.length > 7
      hex_color = color.to(7)
      rgba = tinycolor(hex_color).toRgb()
      opacity = parseInt(color.at(7,8).join(""), 16)/256
      rgba.a = opacity
      new_rgba = tinycolor(rgba)
      new_rgba.toRgbString()
    else
      color

  $scope.has_color = (color) -> if $scope.get_color(color) then "has_color" else false
  $scope.border_color = (bgcolor) -> if $scope.light_or_dark(bgcolor) == "light" then "rgba(0,0,0,.33)" else "rgba(255,255,255,.33)"

  $scope.light_or_dark = (bgcolor) ->
    c = tinycolor(bgcolor)
    d = c.toRgb()
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

  # ----------------------------------------------

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

  # Download and Save ---------------------------------------------------

  update_general_colors = ->
    globals = $scope.jsonTheme.settings[0]
    globals.settings = {}
    globals.settings[gc.name] = gc.color for gc in $scope.gcolors

  $scope.download_theme = ->
    update_general_colors()
    plist = json2plist($scope.jsonTheme)
    blob = new Blob([plist], {type: "text/plain"})
    saveAs blob, "#{$scope.jsonTheme.name}.tmTheme"

  $scope.save_theme = ->
    update_general_colors()
    plist = json2plist($scope.jsonTheme)
    $scope.fs && $scope.fs.root.getFile $scope.files.first(), {create: false}, (fileEntry) ->

      fileEntry.remove ->
        #console.log('File removed.')
        $scope.fs && $scope.fs.root.getFile $scope.files.first(), {create: true}, (fileEntry) ->
          fileEntry.createWriter (fileWriter) ->
            fileWriter.onwriteend = (e) -> console.log "File Saved"
            fileWriter.onerror = (e) -> console.log "Error in writing"
            blob = new Blob([plist], {type: "text/plain"})
            fileWriter.write(blob)
          , FsErrorHandler
        , FsErrorHandler

      , FsErrorHandler
    , FsErrorHandler

  # Theme Stylesheet Generator ------------------------------------------

  $scope.theme_styles = ->
    styles = ""
    if $scope.jsonTheme && $scope.jsonTheme.settings
      for rule in $scope.jsonTheme.settings.compact()
        fg_color  = if rule?.settings?.foreground then $scope.get_color(rule.settings.foreground) else null
        bg_color  = if rule?.settings?.background then $scope.get_color(rule.settings.background) else null
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
    styles

  $scope.theme_gutter = ->
    style = ""
    if $scope.jsonTheme && $scope.jsonTheme.settings && $scope.bg()
      bgcolor = $scope.get_color($scope.bg())
      if $scope.light_or_dark(bgcolor) == "light"
        style = "pre .l:before { background-color: #{$scope.darken(bgcolor, 2)};"
        gutter_foreground = $scope.get_color($scope.gutter_fg()) || $scope.darken(bgcolor, 18)
        style += "color: #{gutter_foreground}};"
      else
        style = "pre .l:before { background-color: #{$scope.lighten(bgcolor, 2)};"
        gutter_foreground = $scope.get_color($scope.gutter_fg()) || $scope.lighten(bgcolor, 12)
        style += "color: #{gutter_foreground}};"
    style

  $scope.theme_selection = ->
    style = ""
    if $scope.jsonTheme && $scope.jsonTheme.settings
      style += "pre::selection {background:transparent}.preview pre *::selection {background:"
      style += "#{$scope.get_color($scope.selection_color())} }"
    style


  # ---------------------------------------------------------------------

  $scope.is_selected = (rule) -> rule == $scope.selected_rule
  $scope.is_hovered = (rule) -> rule == $scope.hovered_rule
  $scope.is_gcolor_selected = (rule) -> rule == $scope.general_selected_rule

  # $scope.selected_gradient = (rule) ->
  #   return "" unless $scope.is_selected(rule)
  #   if $scope.light_or_dark($scope.bg()) == "light" then "selected_bglight" else "selected_bgdark"

  $scope.mark_as_selected = (rule) ->
    $scope.selected_rule = rule
    $scope.edit_popover_visible = false

  $scope.mark_as_selected_gcolor = (rule) -> $scope.general_selected_rule = rule

  # ---------------------------------------------------------------------

  $scope.toggle_edit_popover = (rule, rule_index) ->
    $scope.new_popover_visible = false
    $scope.popover_rule = rule
    $scope.edit_popover_visible = true
    row = $("#scope-lists .rule-#{rule_index}")
    win_height = $(window).height()

    if (win_height - row.offset().top) < 160
      $("#edit-popover").css({
        "top": "auto"
        "left": ""
        "bottom": win_height - row.offset().top
      }).removeClass("on-bottom").addClass("on-top")
    else if row.offset().top < 160
      $("#edit-popover").css({
        "left": ""
        "top": row.offset().top + row.outerHeight()
        "bottom": "auto"
      }).removeClass("on-top").addClass("on-bottom")
    else
      $("#edit-popover").css({
        "top": row.offset().top + (row.outerHeight()/2) - 140
        "left": ""
        "bottom": "auto"
      }).removeClass("on-top").removeClass("on-bottom")

    $("#preview, #gallery").one "click", (e) ->
      $scope.edit_popover_visible = false
      $scope.$digest()
    if $scope.edit_popover_visible
      focus = -> $("#edit-popover .name-input").focus()
      setTimeout(focus, 0)

  $scope.toggle_new_rule_popover = ->
    $scope.edit_popover_visible = false
    $scope.new_rule = Object.clone($scope.new_rule_pristine, true)
    $scope.new_popover_visible = !$scope.new_popover_visible
    if $scope.new_popover_visible
      focus = -> $("#new-popover .name-input").focus()
      setTimeout(focus, 0)

  $scope.close_popover = -> $scope.edit_popover_visible = false

  $scope.hide_all_popovers = ->
    $scope.edit_popover_visible = false
    $scope.toggle_new_rule_popover() if $scope.new_popover_visible

  $scope.delete_rule = (rule) ->
    return unless rule
    rules = $scope.jsonTheme.settings
    index = rules.findIndex(rule)
    rules.remove(rule)
    $scope.selected_rule = rules[index]
    $scope.edit_popover_visible = false

  $scope.add_rule = (new_rule) ->
    $scope.jsonTheme.settings.push(new_rule)
    $scope.toggle_new_rule_popover()
    sidebar = $(".sidebar")
    max_scroll_height = sidebar[0].scrollHeight
    sidebar.animate {"scrollTop": max_scroll_height}, 500, "swing"

  $scope.reset_color = (rule, attr) -> rule.settings[attr] = undefined

  $scope.$watch "edit_popover_visible", (n,o) ->
    if n
      $(".sidebar").css("overflow-y", "hidden")
    else
      $(".sidebar").css("overflow-y", "scroll")


  enable_trasition = -> $('body').removeClass('transition-off')
  setTimeout(enable_trasition, 600)
