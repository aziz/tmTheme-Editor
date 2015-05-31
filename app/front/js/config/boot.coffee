angular.module("templates", [])

Application = angular.module('ThemeEditor',
  [
    'templates'
    'ngSanitize'
    'ui.router'
    'ui.sortable'
    'ui.bootstrap.dropdown'
    'ui.bootstrap.alert'
    'ui.bootstrap.modal'
    'mgcrea.ngStrap.tooltip'
  ]
)

Application.run ['$rootScope', 'throbber', 'Editor', ($rootScope, throbber, Editor) ->
  $rootScope.Editor = Editor

  $rootScope.$on '$stateChangeStart', (event) ->
    throbber.on(full_window: not $rootScope.Editor.Gallery.visible)

  $rootScope.$on '$stateChangeSuccess', (event) ->
    throbber.off()

  $rootScope.$on '$stateChangeError', (event) ->
    throbber.off()

  # $rootScope.$on '$viewContentLoaded', ->
  #   throbber.off()
]
