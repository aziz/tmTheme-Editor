window.Application = angular.module('ThemeEditor',
  ['ngSanitize',
   'ui.sortable',
   'ui.bootstrap.dropdown',
   'ui.bootstrap.alert',
   'ui.bootstrap.modal',
   'mgcrea.ngStrap.tooltip']
)

Application.run ["$rootScope", "$templateCache", ($rootScope, $templateCache) ->
  enable_trasition = -> $('body').removeClass('transition-off')
  setTimeout(enable_trasition, 600)

  $templateCache.put 'template/modalOpenURL.html', '''
    <div shortcut="{ 'enter': 'ok()' }">
      <div class="modal-icon"></div>
      <div class="modal-header">
        <h3 class="modal-title">Open a color scheme from somewhere on the web</h3>
      </div>
      <div class="modal-body">
        <div>URL of the color scheme:</div>
        <div><input focus-me="true" auto-select="true" class="text-input" type="url" ng-model="themeExternalURL"></div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-mac btn-small" ng-click="cancel()">Cancel</button>
        <button class="btn btn-mac btn-small" ng-click="ok()">Open</button>
      </div>
    </div>
  '''
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

angular.module('ui.bootstrap.modal').run(['$templateCache', ($templateCache) ->
    $templateCache.put 'template/modal/backdrop.html', '''
    <div class="modal-backdrop"
         modal-animation-class="fade"
         ng-class="{in: animate}"
         ng-style="{'z-index': 1040 + (index && 1 || 0) + index*10}"></div>
    '''
    $templateCache.put 'template/modal/window.html', '''
    <div modal-render="{{$isRendered}}" tabindex="-1" role="dialog" class="modal"
        modal-animation-class="fade"
      ng-class="{in: animate}" ng-style="{'z-index': 1050 + index*10, display: 'block'}" ng-click="close($event)">
        <div class="modal-dialog" ng-class="size ? 'modal-' + size : ''"><div class="modal-content" modal-transclude></div></div>
    </div>
    '''
])
