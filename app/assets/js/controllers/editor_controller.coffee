Application.controller 'editorController',
['Color', 'Theme', 'ThemeLoader', 'FileManager', 'EditPopover', 'NewPopover', 'HUDEffects', 'throbber', '$filter', '$scope', '$http', '$location', '$timeout', '$window', '$q',
( Color,   Theme,   ThemeLoader,   FileManager,   EditPopover,   NewPopover,   HUDEffects,   throbber,   $filter,   $scope,   $http,   $location,   $timeout,   $window,   $q) ->

  $scope.Color  = Color
  $scope.Theme  = Theme
  $scope.HUD    = HUDEffects
  $scope.EditPopover = EditPopover
  $scope.NewPopover  = NewPopover

  $scope.current_tab    = 'scopes'
  $scope.hovered_rule   = null
  $scope.selected_rule  = null
  $scope.selected_theme = null
  $scope.general_selected_rule = null
  $scope.mark_as_selected_gcolor = (rule) -> $scope.general_selected_rule = rule
  $scope.mark_as_selected = (rule) ->
    $scope.selected_rule = rule
    EditPopover.hide()

  $scope.scopes_filter = { name: '' }
  update_scopes_filter = -> $scope.scopes_filtered = $filter('filter')(Theme.json.settings, $scope.scopes_filter)
  $scope.$watchCollection 'Theme.json', update_scopes_filter
  $scope.$watchCollection 'scopes_filter', update_scopes_filter

  $scope.gallery_filter = {name: ''}
  $scope.toggle_gallery_type_filter = (type) ->
    $scope.gallery_filter.type = if $scope.gallery_filter.type == type then undefined else type

  $scope.gallery_visible = angular.fromJson($.cookie("gallery_visible") || false)
  $scope.toggle_gallery = ->
    if $scope.gallery_visible
      $scope.gallery_visible = false
      $.cookie('gallery_visible', false)
    else
      $scope.gallery_visible = true
      $.cookie('gallery_visible', true)

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

  $scope.themes = []
  ThemeLoader.themes().then (data) -> $scope.themes = data

  $scope.local_themes    = FileManager.list
  $scope.external_themes = angular.fromJson(localStorage.getItem("external_themes") || [])

  $scope.setFiles = (element) ->
    local_files = FileManager.add(element.files)
    # update the location path to the last file
    $q.all(local_files).then (names) ->
      $location.path("/local/#{names.last()}")

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

  # TODO: refactor
  $scope.add_rule = (new_rule) ->
    Theme.json.settings.push(new_rule)
    NewPopover.hide()
    sidebar = $('.sidebar')
    max_scroll_height = sidebar[0].scrollHeight
    sidebar.animate {'scrollTop': max_scroll_height}, 500, 'swing'
    return

  #-------------------------------------------------------------------------
  # TODO: make a external url service
  save_external_to_local_storage = (url) ->
    name = url.split('/').last().replace(/%20/g, ' ')
    current_theme_obj = {name: name, url: url}
    unless $scope.external_themes.find(current_theme_obj)
      $scope.external_themes.push(current_theme_obj)
      localStorage.setItem('external_themes', angular.toJson($scope.external_themes))

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
      theme_obj = $scope.themes.find (t) -> t.name == theme
      gh_match = theme_obj.url.match(gh_pattern)
      if gh_match
        web_url = "https://github.com/#{gh_match[1]}/#{gh_match[2]}/blob/#{gh_match[3]}/#{gh_match[4]}"
        $window.open(web_url)
      else
        $window.open(theme_obj.url)
    return

  # -- LOAD THEME ---------------------------------------------------

  reset_state = ->
    $scope.hide_all_popovers()
    $scope.HUD.hide()
    $scope.scopes_filter.name = ''

  $scope.load_theme = (theme, type) ->
    return if theme.name == $scope.selected_theme
    reset_state()
    $location.path("/#{type}/#{if type == 'url' then theme.url else theme.name}")

  $scope.load_from_url = ->
    url = prompt('Enter the URL of the color scheme: ',
                 'https://raw.github.com/aziz/tmTheme-Editor/master/themes/PlasticCodeWrap.tmTheme')
    if url
      reset_state()
      $location.path("/url/#{url}")

  # -- REMOVE -------------------------------------------------------

  # TODO: merge these two functions
  $scope.remove_local_theme = (theme) ->
    FileManager.remove(theme)
    $location.path('/') if $location.path() == "/local/#{theme.name}"

  $scope.remove_external_theme = (theme) ->
    $scope.external_themes.remove(theme)
    localStorage.setItem('external_themes', angular.toJson($scope.external_themes))
    $location.path('/') if $location.path() == "/url/#{theme.url}"

  # -- SAVE ---------------------------------------------------

  $scope.save_theme = ->
    return unless Theme.json
    if Theme.type == 'Local File'
      FileManager.save($scope.selected_theme, Theme.to_plist())
    else
      # save a local copy of current theme
      FileManager.add_from_memory($scope.selected_theme, Theme.to_plist())
      $location.path("/local/#{$scope.selected_theme}")

  # -- ROUTING ----------------------------------------------
  # TODO: make this a proper angular routing
  $scope.$on '$locationChangeStart', (event, nextLocation, currentLocation) ->
    throbber.on(full_window: not $scope.gallery_visible)

    # There's theme name in URL
    if $location.path() && $location.path().startsWith('/theme/')
      Theme.type = ''
      theme = $location.path().replace('/theme/','')
      $scope.selected_theme = theme

      ThemeLoader.themes().then (data) ->
        return unless Theme.type == ''
        theme_obj = data.find (t) -> t.name == theme
        ThemeLoader.load(theme_obj).success (data) ->
          Theme.process(data)
          throbber.off()

    # There's a theme-url in URL
    else if $location.path() && $location.path().startsWith('/url/')
      Theme.type = 'External URL'
      theme_url = $location.path().replace('/url/','')
      $scope.selected_theme = theme_url.split('/').last().replace(/%20/g, ' ')
      ThemeLoader.load({ url: theme_url }).success (data) ->
        Theme.process(data)
        save_external_to_local_storage(theme_url)
        throbber.off()

    # There's a theme locally saved
    else if $location.path() && $location.path().startsWith('/local/')
      Theme.type = 'Local File'
      $scope.selected_theme = $location.path().replace('/local/','')
      data = FileManager.load($scope.selected_theme)
      Theme.process(data)
      throbber.off()

    # Loading Default theme
    else
      throbber.off()
      $timeout ->
        $location.path('/theme/Monokai')

]
