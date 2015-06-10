angular.module('templates', [])
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

# Production mode
Application.config ['$logProvider','$compileProvider', ($logProvider, $compileProvider) ->
  # $logProvider.debugEnabled false
  # $compileProvider.debugInfoEnabled false
]

Application.run ['$rootScope', 'throbber', 'Editor', ($rootScope, throbber, Editor) ->
  $rootScope.Editor = Editor
]
