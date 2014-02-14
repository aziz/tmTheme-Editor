Application.controller 'editorController',
['Color', 'Theme', 'ThemeLoader', 'throbber', '$scope', '$http', '$location', '$timeout', '$window'],
( Color,   Theme,   ThemeLoader,   throbber,   $scope,   $http,   $location,   $timeout,   $window) ->

  $scope.is_browser_supported = window.chrome
  $scope.fs = null
  $scope.Color = Color
  $scope.Theme = Theme

  $scope.current_tab   = 'scopes'
  $scope.scopes_filter = { name: '' }

  $scope.files = []
  $scope.selected_rule = null

  $scope.popover_rule = {}
  $scope.edit_popover_visible = false
  $scope.new_popover_visible = false
  $scope.new_rule_pristine = {'name':'','scope':'','settings':{}}
  $scope.new_rule = Object.clone($scope.new_rule_pristine)
  $scope.new_property = {property: '', value: ''}

  $scope.gallery = if $.cookie('gallery_state') && $.cookie('gallery_state') == 'slide' then 'slide' else null

  $scope.sortable_options = {
    axis: 'y'
    containment: 'parent'
    helper: (e, tr) ->
      originals = tr.children()
      helper = tr.clone()
      helper.children().each (index) ->
        $(this).width originals.eq(index).width()
      helper
  }

  $scope.shortcuts = {
    'escape': 'hide_all_popovers()',
    'ctrl+n': 'toggle_new_rule_popover()'
  }

  $scope.page_title = ->
    if Theme.json
      Theme.json.name + ' — ' + 'TmTheme Editor'
    else
      'TmTheme Editor'

  $scope.toggle_gallery = ->
    if $scope.gallery
      $scope.gallery = null
      $.cookie('gallery_state', 'closed')
    else
      $scope.gallery = 'slide'
      $.cookie('gallery_state', 'slide')


  # -- Initializing ----------------------------------------------
  $scope.$on '$locationChangeStart', (event, nextLocation, currentLocation) ->
    # console.log 'locationChangeStart'
    # There's theme name in URL
    if $location.path() && $location.path().startsWith('/theme/')
      Theme.type = ''
      theme = $location.path().replace('/theme/','')
    # There's a theme-url in URL
    else if $location.path() && $location.path().startsWith('/url/')
      Theme.type = 'External URL'
      theme_url = $location.path().replace('/url/','')
      # console.log 'Loading from URL (not in the gallery) (#{theme_url})'
    # There's a theme locally saved
    else if $location.path() && $location.path().startsWith('/local/')
      Theme.type = 'Local File'
      # console.log 'Loading from local file system'
    # Loading Default theme
    else
      theme = 'Monokai'
      $location.path('/theme/Monokai')

    throbber.on() unless Theme.type == 'Local File'
    ThemeLoader.themes.success (data) ->
      $scope.available_themes = data
      if theme
        theme_obj = $scope.available_themes.find (t) -> t.name == theme
        ThemeLoader.load(theme_obj).success (data) ->
          Theme.process(data)
          throbber.off()
      else if theme_url
        ThemeLoader.load({ url: theme_url }).success (data) ->
          Theme.process(data)
          save_external_to_local_storage(theme_url)
          throbber.off()


  # File System API -----------------------------------------
  FsInitHandler = (fs) ->
    $scope.fs = fs
    $scope.$apply()

    if $location.path().startsWith('/local/')
      local_theme = $location.path().replace('/local/', '').replace(/%20/g,' ')
      $scope.files.push(local_theme)
      $scope.fs.root.getFile local_theme, {}, ((fileEntry) ->
        fileEntry.file ((file) ->
          reader = new FileReader()
          reader.onloadend = (e) ->
            Theme.process(@result.trim())
            throbber.off()
            $scope.$apply()
          reader.readAsText file
        ), FsErrorHandler
      ), FsErrorHandler

  window.requestFileSystem(window.TEMPORARY, 10*1024*1024,  FsInitHandler, FsErrorHandler)

  read_files = (files) ->
    throbber.on()
    for file in files
      #continue unless f.type.match('tmtheme')
      reader = new FileReader()
      reader.readAsText(file) # Read in the tmtheme file
      reader.onload = do (file) ->
        (e) ->
          xml_data = e.target.result.trim()
          $scope.fs && $scope.fs.root.getFile file.name, {create: true}, (fileEntry) ->
            fileEntry.createWriter (fileWriter) ->
              fileWriter.onwriteend = (e) ->
                $scope.$apply ->
                  $location.path("/local/#{file.name}")
                  list_local_files()
              blob = new Blob([xml_data], {type: 'text/plain'})
              fileWriter.write(blob)
          Theme.process(xml_data)
          $scope.$apply()
          throbber.off()

  $scope.setFiles = (element) ->
    $scope.files.push(file) for file in element.files
    read_files($scope.files)

  $scope.localFiles = []

  list_local_files = ->
    localFiles = []
    dirReader = $scope.fs.root.createReader()
    toArray = (list) -> Array::slice.call list or [], 0
    # Call the reader.readEntries() until no more results are returned.
    readEntries = ->
      dirReader.readEntries ((results) ->
        if results.length
          localFiles = localFiles.concat(toArray(results))
          readEntries()
        else
          $scope.$apply ->
            $scope.localFiles = localFiles
      ), FsErrorHandler
    readEntries() # Start reading dirs.


  $timeout(list_local_files, 500)

  $scope.open_from_url = (theme) ->
    if theme
      return if $scope.selected_theme == theme
      $scope.selected_theme = theme
      $location.path("/url/#{theme.url}")
    else
      url = prompt('Enter the URL of the color scheme: ', 'https://raw.github.com/aziz/tmTheme-Editor/master/themes/PlasticCodeWrap.tmTheme')
      if url
        $location.path("/url/#{url}")

  save_external_to_local_storage = (url) ->
    name = url.split('/').last().replace(/%20/g, ' ')
    current_theme_obj = {name: name, url: url}
    unless $scope.external_themes.find(current_theme_obj)
      $scope.external_themes.push(current_theme_obj)
      localStorage.setItem('external_themes', JSON.stringify($scope.external_themes))


  $scope.remove_external_theme = (theme) ->
    $scope.external_themes.remove(theme)
    localStorage.setItem('external_themes', JSON.stringify($scope.external_themes))
    if $location.path() == "/url/#{theme.url}"
      $location.path('/')

  $scope.external_themes = JSON.parse(localStorage.getItem("external_themes")) or []

  $scope.selected_theme = null
  $scope.is_selected_theme = (theme) -> theme == $scope.selected_theme

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
    evt.dataTransfer.dropEffect = 'copy'

  dropZone.addEventListener 'dragover', handleDragOver, false
  dropZone.addEventListener 'drop', handleFileDrop, false


  # COLOR ----------------------------------------------------

  $scope.border_color = (bgcolor) -> if Color.light_or_dark(bgcolor) == 'light' then 'rgba(0,0,0,.33)' else 'rgba(255,255,255,.33)'

  # move this to color servcie
  $scope.has_color = (color) -> if Color.parse(color) then 'has_color' else false


  # ----------------------------------------------

  $scope.toggle = (fontStyle, rule) ->
    rule.settings = {} unless rule.settings
    rule.settings.fontStyle = '' unless rule.settings.fontStyle
    if $scope.is(fontStyle, rule)
      rule.settings.fontStyle = rule.settings.fontStyle.split(' ').remove(fontStyle).join(' ')
    else
      rule.settings.fontStyle += " #{fontStyle}"

  # Download and Save ---------------------------------------------------

  # TODO: move to Theme Service?
  $scope.download_theme = ->
    Theme.update_general_colors()
    plist = json2plist(Theme.json)
    blob = new Blob([plist], {type: 'text/plain'})
    saveAs blob, "#{Theme.json.name}.tmTheme"

  $scope.save_theme = ->
    Theme.update_general_colors()
    plist = json2plist(Theme.json)
    $scope.fs && $scope.fs.root.getFile $scope.files.first(), {create: false}, (fileEntry) ->

      fileEntry.remove ->
        #console.log('File removed.')
        $scope.fs && $scope.fs.root.getFile $scope.files.first(), {create: true}, (fileEntry) ->
          fileEntry.createWriter (fileWriter) ->
            fileWriter.onwriteend = (e) -> console.log 'File Saved'
            fileWriter.onerror = (e) -> console.log 'Error in writing'
            blob = new Blob([plist], {type: 'text/plain'})
            fileWriter.write(blob)
          , FsErrorHandler
        , FsErrorHandler

      , FsErrorHandler
    , FsErrorHandler



  # ---------------------------------------------------------------------

  $scope.is_selected = (rule) -> rule == $scope.selected_rule
  $scope.is_hovered = (rule) -> rule == $scope.hovered_rule
  $scope.is_gcolor_selected = (rule) -> rule == $scope.general_selected_rule

  $scope.mark_as_selected = (rule) ->
    $scope.selected_rule = rule
    $scope.edit_popover_visible = false

  $scope.mark_as_selected_gcolor = (rule) -> $scope.general_selected_rule = rule

  # ---------------------------------------------------------------------

  $scope.toggle_edit_popover = (rule, rule_index) ->
    $scope.popover_rule = rule
    $scope.new_popover_visible = false
    $scope.edit_popover_visible = true
    row = $("#scope-lists .rule-#{rule_index}")
    win_height = $(window).height()
    popover = $('#edit-popover')

    if (win_height - row.offset().top) < 160
      popover.css({
        'top': 'auto'
        'left': ''
        'bottom': win_height - row.offset().top
      }).removeClass('on-bottom').addClass('on-top')
    else if row.offset().top < 160
      popover.css({
        'left': ''
        'top': row.offset().top + row.outerHeight()
        'bottom': 'auto'
      }).removeClass('on-top').addClass('on-bottom')
    else
      popover.css({
        'top': row.offset().top + (row.outerHeight()/2) - 140
        'left': ''
        'bottom': 'auto'
      }).removeClass('on-top').removeClass('on-bottom')

    $('#preview, #gallery').one 'click', (e) ->
      $scope.$apply ->
        $scope.edit_popover_visible = false

    return

  $scope.toggle_new_rule_popover = ->
    $scope.edit_popover_visible = false
    $scope.new_rule = Object.clone($scope.new_rule_pristine, true)
    $scope.new_popover_visible = !$scope.new_popover_visible

  $scope.close_popover = -> $scope.edit_popover_visible = false

  $scope.hide_all_popovers = ->
    $scope.edit_popover_visible = false
    $scope.toggle_new_rule_popover() if $scope.new_popover_visible

  $scope.delete_rule = (rule) ->
    return unless rule
    rules = Theme.json.settings
    index = rules.findIndex(rule)
    rules.remove(rule)
    $scope.selected_rule = rules[index]
    $scope.edit_popover_visible = false

  $scope.add_rule = (new_rule) ->
    Theme.json.settings.push(new_rule)
    $scope.toggle_new_rule_popover()
    sidebar = $('.sidebar')
    max_scroll_height = sidebar[0].scrollHeight
    sidebar.animate {'scrollTop': max_scroll_height}, 500, 'swing'

  $scope.reset_color = (rule, attr) ->
    delete rule.settings[attr]

  #-------------------------------------------------------------------------
  $scope.colors_hud_open = false
  $scope.brightness = 0
  $scope.saturation = 0

  $scope.toggle_colors_hud = ->
    if !$scope.colors_hud_open
      $scope.original_colors = Object.clone(Theme.json.settings, true)
    $scope.colors_hud_open = !$scope.colors_hud_open

  $scope.close_hud = -> $scope.colors_hud_open = false

  $scope.reset_color_changes = ->
    Theme.json.settings = Object.clone($scope.original_colors, true)
    $scope.brightness = 0
    $scope.saturation = 0

  $scope.filter_colors = (filter) ->
    for rule in Theme.json.settings
      if rule.settings
        if rule.settings.foreground
          rule.settings.foreground = tinycolor[filter](rule.settings.foreground).toHexString()
        if rule.settings.background
          rule.settings.background = tinycolor[filter](rule.settings.background).toHexString()
    for rule in Theme.gcolors
      rule.color = tinycolor[filter](rule.color).toHexString()
    $scope.original_colors = Object.clone(Theme.json.settings, true)

  $scope.update_colors = (->
    for rule,i in $scope.original_colors
      if rule.scope && rule.settings
        if rule.settings.foreground
          Theme.json.settings[i].settings.foreground = tinycolor.brightness_contrast( rule.settings.foreground, $scope.brightness, $scope.saturation/100 ).toHexString()
        if rule.settings.background
          Theme.json.settings[i].settings.background = tinycolor.brightness_contrast( rule.settings.background, $scope.brightness, $scope.saturation/100.0 ).toHexString()

  ).throttle(20)
  #-------------------------------------------------------------------------

  $scope.open_theme_url = ->
    gh_pattern = /https?:\/\/raw2?\.github\.com\/(.+?)\/(.+?)\/(.+?)\/(.+)/
    if Theme.type == 'External URL'
      url = $location.path().replace('/url/','')
      gh_match = url.match(gh_pattern)
      if gh_match
        web_url = "https://github.com/#{gh_match[1]}/#{gh_match[2]}/blob/#{gh_match[3]}/#{gh_match[4]}"
        $window.open(web_url)
      else
        $window.open(url)
    else
      theme =  $location.path().replace('/theme/','')
      theme_obj = $scope.available_themes.find (t) -> t.name == theme
      gh_match = theme_obj.url.match(gh_pattern)
      if gh_match
        web_url = "https://github.com/#{gh_match[1]}/#{gh_match[2]}/blob/#{gh_match[3]}/#{gh_match[4]}"
        $window.open(web_url)
      else
        $window.open(theme_obj.url)

    return


  $scope.$watch 'edit_popover_visible', (n,o) ->
    if n
      $('.sidebar').css('overflow-y', 'hidden')
    else
      $('.sidebar').css('overflow-y', 'scroll')
