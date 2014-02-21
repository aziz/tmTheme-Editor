Application.controller 'editorController',
['Color', 'Theme', 'ThemeLoader', 'EditPopover', 'NewPopover', 'HUDEffects', 'throbber', '$cookies', '$filter', '$scope', '$http', '$location', '$timeout', '$window',
( Color,   Theme,   ThemeLoader,   EditPopover,   NewPopover,   HUDEffects,   throbber,   $cookies,   $filter,   $scope,   $http,   $location,   $timeout,   $window) ->

  $scope.is_browser_supported = if $window.chrome then true else false
  $scope.themes = []
  $scope.Color  = Color
  $scope.Theme  = Theme
  $scope.HUD    = HUDEffects
  $scope.EditPopover = EditPopover
  $scope.NewPopover  = NewPopover

  $scope.current_tab   = 'scopes'

  $scope.scopes_filter = { name: '' }
  update_scopes_filter = -> $scope.scopes_filtered = $filter('filter')(Theme.json.settings, $scope.scopes_filter)
  $scope.$watchCollection 'Theme.json', update_scopes_filter
  $scope.$watchCollection 'scopes_filter', update_scopes_filter

  $scope.fs = null
  $scope.files = []
  $scope.hovered_rule = null
  $scope.selected_rule = null
  $scope.selected_theme = null
  $scope.general_selected_rule = null
  $scope.mark_as_selected_gcolor = (rule) -> $scope.general_selected_rule = rule
  $scope.mark_as_selected = (rule) ->
    $scope.selected_rule = rule
    EditPopover.hide()


  $scope.sortable_options = {
    axis: 'y'
    containment: 'parent'
    stop: (event, ui) -> $("#sortableHelper").remove()
    helper: (e, tr) ->
      originals = tr.children()
      helper = tr.clone().attr("id", "sortableHelper")
      helper.children().each (index) ->
        $(this).width originals.eq(index).width()
      helper
  }

  $scope.shortcuts = {
    'escape': 'hide_all_popovers()',
    'ctrl+n': 'NewPopover.show()'
  }

  # TODO return promise
  ThemeLoader.themes.success (data) ->
    for theme in data
      theme.type = if theme.light then 'light' else 'dark'
    $scope.themes = data

  $scope.gallery_visible = if $cookies.gallery_state and $cookies.gallery_state == 'slide' then true else false
  $scope.toggle_gallery = ->
    if $scope.gallery_visible
      $scope.gallery_visible = false
      $cookies.gallery_state = 'closed'
    else
      $scope.gallery_visible = true
      $cookies.gallery_state = 'slide'


  # -- Initializing ----------------------------------------------
  $scope.$on '$locationChangeStart', (event, nextLocation, currentLocation) ->
    # There's theme name in URL
    if $location.path() && $location.path().startsWith('/theme/')
      Theme.type = ''
      theme = $location.path().replace('/theme/','')
      $scope.selected_theme = theme
    # There's a theme-url in URL
    else if $location.path() && $location.path().startsWith('/url/')
      Theme.type = 'External URL'
      theme_url = $location.path().replace('/url/','')
      $scope.selected_theme = theme_url.split('/').last().replace(/%20/g, ' ')
    # There's a theme locally saved
    else if $location.path() && $location.path().startsWith('/local/')
      Theme.type = 'Local File'
      $scope.selected_theme = $location.path().replace('/local/','')
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

  # File System API ----------------------------------------------
  $scope.setFiles = (element) ->
    $scope.files.push(file) for file in element.files
    read_files($scope.files)

  $scope.localFiles = []
  $scope.external_themes = angular.fromJson(localStorage.getItem("external_themes")) or []

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

  list_local_files = ->
    return unless $scope.fs
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

  save_external_to_local_storage = (url) ->
    name = url.split('/').last().replace(/%20/g, ' ')
    current_theme_obj = {name: name, url: url}
    unless $scope.external_themes.find(current_theme_obj)
      $scope.external_themes.push(current_theme_obj)
      localStorage.setItem('external_themes', angular.toJson($scope.external_themes))

  $timeout(list_local_files, 500)

  $window.requestFileSystem && $window.requestFileSystem($window.TEMPORARY, 10*1024*1024,  FsInitHandler, FsErrorHandler)

  # Drag & Drop --------------------------------------------------------
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

  # ---------------------------------------------------------------------

  $scope.$watch 'EditPopover.visible', (visible) ->
    if visible
      $('#preview, #gallery').one 'click', (e) ->
        $scope.$apply ->
          EditPopover.visible = false

  $scope.hide_all_popovers = ->
    $scope.EditPopover.hide()
    $scope.NewPopover.hide()

  $scope.delete_rule = (rule) ->
    return unless rule
    rules = Theme.json.settings
    index = rules.findIndex(rule)
    rules.remove(rule)
    $scope.selected_rule = rules[index]
    EditPopover.hide()

  $scope.add_rule = (new_rule) ->
    Theme.json.settings.push(new_rule)
    NewPopover.hide()
    sidebar = $('.sidebar')
    max_scroll_height = sidebar[0].scrollHeight
    sidebar.animate {'scrollTop': max_scroll_height}, 500, 'swing'
    return

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
      theme = $location.path().replace('/theme/','')
      theme_obj = $scope.available_themes.find (t) -> t.name == theme
      gh_match = theme_obj.url.match(gh_pattern)
      if gh_match
        web_url = "https://github.com/#{gh_match[1]}/#{gh_match[2]}/blob/#{gh_match[3]}/#{gh_match[4]}"
        $window.open(web_url)
      else
        $window.open(theme_obj.url)
    return

  $scope.filter = {name: ''}

  $scope.toggle_type_filter = (type) ->
    $scope.filter.type = if $scope.filter.type == type then undefined else type

  # -- LOAD THEME ----------------------------------------------------------
  reset_state = ->
    $scope.hide_all_popovers()
    $scope.HUD.hide()
    $scope.scopes_filter.name = ''

  $scope.load_gallery_theme = (theme) ->
    return if theme.name == $scope.selected_theme
    reset_state()
    $location.path("/theme/#{theme.name}")

  $scope.load_external_theme = (theme) ->
    if theme
      return if theme.name == $scope.selected_theme
      reset_state()
      $location.path("/url/#{theme.url}")
    else
      url = prompt('Enter the URL of the color scheme: ',
                   'https://raw.github.com/aziz/tmTheme-Editor/master/themes/PlasticCodeWrap.tmTheme')
      if url
        $location.path("/url/#{url}")

  $scope.load_local_theme = (theme) ->
    return if theme.name == $scope.selected_theme
    throbber.on()
    reset_state()
    Theme.theme_type = 'Local File'
    $scope.files.push(theme.name)
    $scope.fs.root.getFile theme.name, {}, ((fileEntry) ->
      fileEntry.file ((file) ->
        reader = new FileReader()
        reader.onloadend = (e) ->
          Theme.process(@result.trim())
          $location.path("/local/#{theme.name}")
          throbber.off()
          $scope.$apply()
        reader.readAsText file
      ), FsErrorHandler
    ), FsErrorHandler

  # -- SAVE ---------------------------------------------------

  # TODO: this is broken
  $scope.save_theme = ->
    Theme.update_general_colors()
    plist = json_to_plist(Theme.json)
    $scope.fs && $scope.fs.root.getFile $scope.files.first(), {create: false}, (fileEntry) ->
      fileEntry.remove ->
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

  # -- REMOVE -------------------------------------------------------

  $scope.remove_local_theme = (theme) ->
    $scope.fs.root.getFile theme.name, {create: false}, ((fileEntry) ->
      fileEntry.remove (->
        $scope.localFiles.remove(theme)
        if $location.path() == "/local/#{theme.name}"
          $location.path('/')
        $scope.$apply()
      ), FsErrorHandler
    ), FsErrorHandler

  $scope.remove_external_theme = (theme) ->
    $scope.external_themes.remove(theme)
    localStorage.setItem('external_themes', angular.toJson($scope.external_themes))
    if $location.path() == "/url/#{theme.url}"
      $location.path('/')


  for own k,v of $scope
    if k[0] != "$" and angular.isFunction(v)
      $scope[k] = v.monitor($scope)

  $scope.$report = ->
    table = for own k,v of $scope
      if k[0] != "$" and angular.isFunction(v)
        { name: k, calls: v.calls_counter, time: v.last_call_time }
    console.table table

]
