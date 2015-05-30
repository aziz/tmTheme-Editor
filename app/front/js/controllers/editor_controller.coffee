Application.controller 'editorController',
['current_theme', 'Color', 'Theme', 'ThemeLoader', 'FileManager', 'EditPopover', 'NewPopover', 'HUDEffects', 'throbber', '$filter', '$scope', '$location','$window', '$q', '$modal'
( current_theme,   Color,   Theme,   ThemeLoader,   FileManager,   EditPopover,   NewPopover,   HUDEffects,   throbber,   $filter,   $scope,   $location,  $window,   $q,   $modal) ->

  default_external_theme_url = 'https://raw.githubusercontent.com/theymaybecoders/sublime-tomorrow-theme/master/Tomorrow.tmTheme'
  $scope.version = $("#version").attr("content")

  $scope.Color  = Color
  $scope.Theme  = Theme
  $scope.HUD    = HUDEffects
  $scope.EditPopover = EditPopover
  $scope.NewPopover  = NewPopover

  $scope.alerts = []
  $scope.closeAlert = (index) -> $scope.alerts.splice(index, 1)

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
  update_scopes_filter = ->
    return unless Theme.json
    $scope.scopes_filtered = $filter('filter')(Theme.json.settings, $scope.scopes_filter)
  $scope.$watchCollection 'Theme.json', update_scopes_filter
  $scope.$watchCollection 'Theme.json.settings', update_scopes_filter
  $scope.$watchCollection 'scopes_filter', update_scopes_filter

  $scope.gallery_filter = {name: ''}
  $scope.toggle_gallery_type_filter = (type) ->
    if $scope.gallery_filter.color_type == type
      delete $scope.gallery_filter.color_type
    else
      $scope.gallery_filter.color_type = type

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
    'escape': 'hide_all_popovers()'
    'ctrl+n': 'NewPopover.show()'
  }

  $scope.themes = []
  ThemeLoader.themes.then (data) -> $scope.themes = data

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
    return

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
    bg_type = Color.light_or_dark(Theme.bg())
    current_theme_obj = {name: name, url: url, color_type: bg_type }
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

  $scope.clear_cache = ->
    FileManager.clear_cache()

  $scope.load_from_url = ->
    modalInstance = $modal.open(
      animation: false
      backdrop: true
      templateUrl: '/template/modalOpenURL.ng.html'
      controller: 'ModalOpenURLController'
      resolve: {
        themeExternalURL: -> default_external_theme_url
      }
    )
    modalInstance.result.then (themeURL) ->
      reset_state()
      $location.path("/url/#{themeURL}")
      return
    return

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

  update_local_theme = ->
    current_theme_obj = {name: $scope.selected_theme, color_type: Color.light_or_dark(Theme.bg())}
    index = $scope.local_themes.findIndex((item) -> item.name == current_theme_obj.name)
    $scope.local_themes[index] = current_theme_obj
    localStorage.setItem('local_files', angular.toJson($scope.local_themes))

  process_theme = (data) ->
    processed = Theme.process(data)
    if processed.error
      console.log processed.error
      # $location.path(previous_path)
      $scope.alerts.push { type: 'danger', msg: processed.msg }
      false
    else
      save_external_to_local_storage(current_theme.url) if current_theme.url
      true

  handle_load_error = (error) ->
    # $location.path(previous_path)
    $scope.alerts.push { type: 'danger', msg: error }

  current_theme.data.then(process_theme, handle_load_error)
  $scope.Theme.type = current_theme.type
  $scope.selected_theme = current_theme.name

]
