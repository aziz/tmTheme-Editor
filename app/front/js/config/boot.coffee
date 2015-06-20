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
    'minicolors'
    'monospaced.elastic'
  ]
)

Application.run ['$rootScope', 'Editor', ($rootScope, Editor) ->
  $rootScope.Editor = Editor
  return
]

# Production mode
# Application.config ['$logProvider','$compileProvider', ($logProvider, $compileProvider) ->
#   $logProvider.debugEnabled false
#   $compileProvider.debugInfoEnabled false
# ]
