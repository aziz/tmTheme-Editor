Application.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', ($stateProvider, $urlRouterProvider, $locationProvider) ->
    $locationProvider.hashPrefix '!'
    $urlRouterProvider.otherwise '/theme/Monokai'

    $stateProvider
    .state 'theme', {
      url: '/theme'
      views: {
        '@': {
          templateUrl: 'template/editor.ng.html'
        }
        'gallery@theme': {
          controller: 'galleryController'
          templateUrl: 'template/gallery.ng.html'
        }
      }
    }
    .state 'theme.gallery', {
      url: '^/theme/:theme'
      views: {
        'main': {
          templateUrl: 'template/main.ng.html'
          controller: 'editorController'
        }
      }
      resolve: Application.editorData
    }

    .state 'url', {
      url: '/url'
      views: {
        '@': {
          templateUrl: 'template/editor.ng.html'
        }
        'gallery@url': {
          controller: 'galleryController'
          templateUrl: 'template/gallery.ng.html'
        }
      }
    }
    .state 'url.gallery', {
      url: '^/url/*theme'
      views: {
        'main': {
          templateUrl: 'template/main.ng.html'
          controller: 'editorController'
        }
      }
      resolve: Application.urlData
    }

    .state 'local', {
      url: '/local'
      views: {
        '@': {
          templateUrl: 'template/editor.ng.html'
        }
        'gallery@local': {
          controller: 'galleryController'
          templateUrl: 'template/gallery.ng.html'
        }
      }
    }
    .state 'local.gallery', {
      url: '^/local/:theme'
      views: {
        'main': {
          templateUrl: 'template/main.ng.html'
          controller: 'editorController'
        }
      }
      resolve: Application.localData
    }
    .state 'stats', {
      url: '/stats'
      templateUrl: 'template/stats.ng.html'
      controller: 'statsController'
    }
    return
]
