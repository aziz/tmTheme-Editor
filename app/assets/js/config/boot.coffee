window.Application = angular.module('ThemeEditor',
  ['ngSanitize',
   'ui.sortable',
   'ui.bootstrap.dropdown',
   'ui.bootstrap.alert',
   'mgcrea.ngStrap.tooltip']
)

Application.run ["$rootScope", ($rootScope) ->
  enable_trasition = -> $('body').removeClass('transition-off')
  setTimeout(enable_trasition, 600)
]

angular.module('ui.bootstrap.alert').run(['$templateCache', ($templateCache) ->
    $templateCache.put 'template/alert/alert.html', '''
    <div class="alert" ng-class="['alert-' + (type || 'warning'), closeable ? 'alert-dismissable' : null]" role="alert">
        <button ng-show="closeable" type="button" class="close" ng-click="close()">
            <span aria-hidden="true">&times;</span>
            <span class="sr-only">Close</span>
        </button>
        <div ng-transclude></div>
    </div>
    '''
])
