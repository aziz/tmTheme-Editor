Application.controller 'editorController',
['current_theme', 'Color', 'Editor', 'Theme', 'ColorPicker', 'ThemeLoader', 'FileManager', 'EditPopover', 'NewPopover', 'HUDEffects', 'throbber', '$filter', '$scope', '$location','$window', '$q', '$modal'
( current_theme,   Color,   Editor,   Theme,   ColorPicker,   ThemeLoader,   FileManager,   EditPopover,   NewPopover,   HUDEffects,   throbber,   $filter,   $scope,   $location,  $window,   $q,   $modal) ->

  default_external_theme_url = 'https://raw.githubusercontent.com/theymaybecoders/sublime-tomorrow-theme/master/Tomorrow.tmTheme'

  $scope.Color = Color
  $scope.Theme = Theme
  $scope.HUD   = HUDEffects
  $scope.EditPopover = EditPopover
  $scope.NewPopover  = NewPopover
  $scope.CP  = ColorPicker

  # TODO: alerts controller and service
  $scope.alerts = []
  $scope.closeAlert = (index) -> $scope.alerts.splice(index, 1)

  $scope.current_tab    = 'scopes'
  $scope.hovered_rule   = null
  $scope.selected_rule  = null
  $scope.general_selected_rule = null
  $scope.mark_as_selected_gcolor = (rule) -> $scope.general_selected_rule = rule

  $scope.mark_as_selected = (rule) ->
    $scope.selected_rule = rule
    EditPopover.hide()

  $scope.scopes_filter = { name: '' }
  update_scopes_filter = ->
    return unless Theme.json
    $scope.scopes_filtered = $filter('filter')(Theme.json.settings, $scope.scopes_filter)

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

  # TODO: Should be moved to FileManager
  $scope.setFiles = (element) ->
    local_files = FileManager.add_local_theme(element.files)
    $q.all(local_files).then (names) ->
      $location.path("/editor/local/#{names.last()}")

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

  $scope.add_rule = (new_rule) ->
    Theme.json.settings.push(new_rule)
    NewPopover.hide()
    # TODO: refactor
    sidebar = $('.sidebar')
    max_scroll_height = sidebar[0].scrollHeight
    sidebar.animate {'scrollTop': max_scroll_height}, 500, 'swing'
    return

  $scope.open_theme_url = ->
    url = current_theme.url
    $window.open(url)
    return

  $scope.clear_cache = ->
    FileManager.clear_cache()

  $scope.load_from_url_modal = ->
    modalInstance = $modal.open(
      animation: false
      backdrop: true
      templateUrl: 'template/modalOpenURL.html'
      controller: 'ModalOpenURLController'
      resolve: {
        themeExternalURL: -> default_external_theme_url
      }
    )
    modalInstance.result.then (themeURL) ->
      reset_state()
      $location.path("/editor/url/#{themeURL}")
      return
    return

  $scope.save_theme = ->
    return unless Theme.json
    if Theme.type == 'Local File'
      FileManager.save(current_theme.name, Theme.to_plist())
    else
      # save a local copy of current theme
      FileManager.add_from_memory(current_theme.name, Theme.to_plist())
      $location.path("/editor/local/#{current_theme.name}")

  #-------------------------------------------------------------------------
  $scope.$watchCollection 'Theme.json', update_scopes_filter
  $scope.$watchCollection 'Theme.json.settings', update_scopes_filter
  $scope.$watchCollection 'scopes_filter', update_scopes_filter
  $scope.$watch 'EditPopover.visible', (visible) ->
    if visible
      $('#preview, #gallery').one 'click', (e) ->
        $scope.$apply ->
          EditPopover.visible = false
        return
  #-------------------------------------------------------------------------

  save_external_to_local_storage = ->
    theme_obj = {
      name: current_theme.name,
      url: current_theme.url,
      color_type: Color.light_or_dark(Theme.bg.color)
    }
    FileManager.add_external_theme(theme_obj)

  update_local_theme = ->
    current_theme_obj = {name: current_theme.name, color_type: Color.light_or_dark(Theme.bg.color)}
    locals = FileManager.local_themes
    index = locals.findIndex((item) -> item.name == current_theme_obj.name)
    locals[index] = current_theme_obj
    FileManager.local_themes = locals

  reset_state = ->
    $scope.hide_all_popovers()
    $scope.HUD.hide()
    $scope.scopes_filter.name = ''

  process_theme = (data) ->
    Editor.current_theme = current_theme
    $scope.Theme.type = current_theme.type
    processed = Theme.process(data)
    if processed.error
      console.log processed.error
      # $location.path(previous_path)
      $scope.alerts.push { type: 'danger', msg: processed.msg }
      false
    else
      save_external_to_local_storage() if current_theme.type == 'External URL'
      update_local_theme() if current_theme.type == 'Local File'
      true

  handle_load_error = (error) ->
    # $location.path(previous_path)
    $scope.alerts.push { type: 'danger', msg: error }

  current_theme.data.then(process_theme, handle_load_error)

]
