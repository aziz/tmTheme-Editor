Application.controller 'editorController',
['Color', 'Theme', 'ThemeLoader', 'EditPopover', 'NewPopover', 'HUDEffects', 'throbber', '$scope', '$http', '$location', '$timeout', '$window'],
( Color,   Theme,   ThemeLoader,   EditPopover,   NewPopover,   HUDEffects,   throbber,   $scope,   $http,   $location,   $timeout,   $window) ->

  $scope.is_browser_supported = $window.chrome
  $scope.themes = []
  $scope.Color = Color
  $scope.Theme = Theme
  $scope.HUD   = HUDEffects
  $scope.EditPopover = EditPopover
  $scope.NewPopover  = NewPopover

  $scope.current_tab   = 'scopes'
  $scope.scopes_filter = { name: '' }

  $scope.fs = null
  $scope.files = []
  $scope.selected_rule = null

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
    'ctrl+n': 'NewPopover.show()'
  }

  ThemeLoader.themes.success (data) ->
    for theme in data
      theme.type = if theme.light then 'light' else 'dark'
    $scope.themes = data


  $scope.page_title = ->
    if Theme.json
      Theme.json.name + ' — ' + 'TmTheme Editor'
    else
      'TmTheme Editor'

  $scope.gallery_visible = if $.cookie('gallery_state') and $.cookie('gallery_state') == 'slide' then true else false
  $scope.toggle_gallery = ->
    if $scope.gallery_visible
      $scope.gallery_visible = false
      $.cookie('gallery_state', 'closed')
    else
      $scope.gallery_visible = true
      $.cookie('gallery_state', 'slide')

  # TODO make sure selected theme is always set when loading in different modes
  $scope.selected_theme = null
  $scope.is_selected_theme = (theme) -> theme == $scope.selected_theme

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
    # There's a theme locally saved
    else if $location.path() && $location.path().startsWith('/local/')
      Theme.type = 'Local File'
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

  $window.requestFileSystem($window.TEMPORARY, 10*1024*1024,  FsInitHandler, FsErrorHandler)

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
      url = prompt 'Enter the URL of the color scheme: ', 'https://raw.github.com/aziz/tmTheme-Editor/master/themes/PlasticCodeWrap.tmTheme'
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

  # Save ---------------------------------------------------

  # TODO: this is broken
  $scope.save_theme = ->
    Theme.update_general_colors()
    plist = json_to_plist(Theme.json)
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
    EditPopover.hide()

  $scope.mark_as_selected_gcolor = (rule) -> $scope.general_selected_rule = rule

  # ---------------------------------------------------------------------

  $scope.$watch 'EditPopover.visible', (visible) ->
    if visible
      $('#preview, #gallery').one 'click', (e) ->
        $scope.$apply ->
          EditPopover.visible = false

  $scope.hide_all_popovers = ->
    $scope.EditPopover.hide()
    $scope.NewPopover.hide()

  # TODO move it theme service, make a rule service
  $scope.delete_rule = (rule) ->
    return unless rule
    rules = Theme.json.settings
    index = rules.findIndex(rule)
    rules.remove(rule)
    $scope.selected_rule = rules[index]
    EditPopover.hide()

  # TODO move it theme service, make a rule service
  $scope.add_rule = (new_rule) ->
    Theme.json.settings.push(new_rule)
    NewPopover.hide()
    sidebar = $('.sidebar')
    max_scroll_height = sidebar[0].scrollHeight
    sidebar.animate {'scrollTop': max_scroll_height}, 500, 'swing'
    return

  # TODO move it theme service, make a rule service
  $scope.reset_color = (rule, attr) ->
    delete rule.settings[attr]

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

  # ----- from gallery controller ------------------------------------
  $scope.filter = {name: ''}

  $scope.load_theme = (theme) ->
    return if $scope.selected_theme == theme
    $scope.hide_all_popovers()
    Theme.theme_type = ''
    $scope.scopes_filter.name = ''
    $location.search('local', null)
    $location.path("/theme/#{theme.name}")
    $scope.selected_theme = theme

  $scope.toggle_type_filter = (type) ->
    $scope.filter.type = if $scope.filter.type == type then undefined else type

  # -- Loading Local Files -------------------------------------------
  $scope.load_local_theme = (theme) ->
    return if $scope.selected_theme == theme
    throbber.on()
    $scope.hide_all_popovers()
    Theme.theme_type = 'Local File'
    $scope.scopes_filter.name = ''
    $scope.selected_theme = theme
    $scope.files.push(theme.name)
    $scope.fs.root.getFile theme.name, {}, ((fileEntry) ->
      fileEntry.file ((file) ->
        reader = new FileReader()
        reader.onloadend = (e) ->
          Theme.process(@result.trim())
          $location.path("/local/#{theme.name}")
          $scope.$apply()
          throbber.off()
        reader.readAsText file
      ), FsErrorHandler
    ), FsErrorHandler

  $scope.remove_local_theme = (theme) ->
    $scope.fs.root.getFile theme.name, {create: false}, ((fileEntry) ->
      fileEntry.remove (->
        # console.log 'File removed.'
        $scope.localFiles.remove(theme)
        if $location.path() == "/local/#{theme.name}"
          # console.log 'removing deleted theme from path'
          $location.path('/')
        $scope.$apply()
      ), FsErrorHandler
    ), FsErrorHandler
