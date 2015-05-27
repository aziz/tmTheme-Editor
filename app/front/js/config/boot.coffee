angular.module("templates", [])

Application = angular.module('ThemeEditor',
  [
    'templates'
    'ngSanitize'
    'ui.sortable'
    'ui.bootstrap.dropdown'
    'ui.bootstrap.alert'
    'ui.bootstrap.modal'
    'mgcrea.ngStrap.tooltip'
  ]
)

Application.run ["$rootScope", "$templateCache", ($rootScope) ->
  enable_trasition = -> $('body').removeClass('transition-off')
  setTimeout(enable_trasition, 1200)
]
