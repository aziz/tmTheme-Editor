Application.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', ($stateProvider, $urlRouterProvider, $locationProvider) ->
    $locationProvider.hashPrefix '!'
    $urlRouterProvider.otherwise 'editor/theme/Monokai'

    $stateProvider
    .state 'editor', {
      url: '/editor'
      views: {
        '@': {
          templateUrl: 'template/editor.html'
        }
        'gallery@editor': {
          controller: 'galleryController'
          templateUrl: 'template/gallery.html'
        }
      }
    }

    .state 'editor.gallery', {
      url: '^/editor/theme/:theme'
      views: {
        'main': {
          templateUrl: 'template/main.html'
          controller: 'editorController'
        }
      }
      resolve: Application.editorData
    }

    .state 'editor.url', {
      url: '^/editor/url/*theme'
      views: {
        'main': {
          templateUrl: 'template/main.html'
          controller: 'editorController'
        }
      }
      resolve: Application.urlData
    }

    .state 'editor.local', {
      url: '^/editor/local/:theme'
      views: {
        'main': {
          templateUrl: 'template/main.html'
          controller: 'editorController'
        }
      }
      resolve: Application.localData
    }

    .state 'stats', {
      url: '/stats'
      templateUrl: 'template/stats.html'
      controller: 'statsController'
    }
    return
]
