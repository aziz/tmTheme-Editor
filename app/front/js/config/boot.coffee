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

  # $rootScope.$on '$routeChangeStart', (event) ->
  #   throbber.on(full_window: true)

  # $rootScope.$on '$routeChangeSucces', (event) ->
  #   throbber.off()

  # $rootScope.$on '$routeChangeError', (event) ->
  #   throbber.off()

  $rootScope.$on '$viewContentLoaded', ->
    enable_trasition = -> $('.transition-off').removeClass('transition-off')
    setTimeout(enable_trasition, 1200)
    throbber.off()
]
