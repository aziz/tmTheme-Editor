angular.module("templates", [])

Application = angular.module('ThemeEditor',
  [
    'templates'
    'ngSanitize'
    'ngRoute'
    'ui.sortable'
    'ui.bootstrap.dropdown'
    'ui.bootstrap.alert'
    'ui.bootstrap.modal'
    'mgcrea.ngStrap.tooltip'
  ]
)

Application.run ['$rootScope', 'throbber', 'Editor', ($rootScope, throbber, Editor) ->
  $rootScope.Editor = Editor

  $rootScope.$on '$routeChangeStart', (event) ->
    throbber.on(full_window: true)

  $rootScope.$on '$routeChangeSucces', (event) ->
    throbber.off()

  $rootScope.$on '$routeChangeError', (event) ->
    throbber.off()

  $rootScope.$on '$viewContentLoaded', ->
    enable_trasition = -> $('.transition-off').removeClass('transition-off')
    setTimeout(enable_trasition, 1200)
    throbber.off()
]

Application.editorData = {
  current_theme: ['$route', 'ThemeLoader', ($route, ThemeLoader) ->
    theme = $route.current.params.theme
    ThemeLoader.themes.then (data) ->
      theme_obj = data.find (t) -> t.name == theme
      return {
        data: ThemeLoader.load(theme_obj)
        name: theme
        url: theme_obj.url
        type: ''
      }
  ]
}

Application.urlData = {
  current_theme: ['$route', 'ThemeLoader', ($route, ThemeLoader) ->
    theme = $route.current.params.theme
    return {
      data: ThemeLoader.load({ url: theme })
      name: theme.split('/').last().replace(/%20/g, ' ')
      url:  theme
      type: 'External URL'
    }
  ]
}

Application.localData = {
  current_theme: ['$route', 'FileManager', '$q', ($route, FileManager, $q) ->
    theme = $route.current.params.theme
    deferred = $q.defer()
    data = FileManager.load(theme)
    deferred.resolve(data)
    return {
      data: deferred.promise
      name: theme
      type: 'Local File'
    }
  ]
}

Application.config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $locationProvider.hashPrefix '!'
    $routeProvider
    .when '/theme/:theme', {
      templateUrl: 'template/editor.ng.html'
      controller: 'editorController'
      resolve: Application.editorData
    }
    .when '/url/:theme*', {
      templateUrl: 'template/editor.ng.html'
      controller: 'editorController'
      resolve: Application.urlData
    }
    .when '/local/:theme', {
      templateUrl: 'template/editor.ng.html'
      controller: 'editorController'
      resolve: Application.localData
    }
    .when '/stats', {
      templateUrl: 'template/stats.ng.html'
      controller: 'statsController'
    }
    .otherwise { redirectTo: '/theme/Monokai' }
    return
]
