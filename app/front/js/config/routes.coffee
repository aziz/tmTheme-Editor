Application.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', ($stateProvider, $urlRouterProvider, $locationProvider) ->
    $locationProvider.hashPrefix '!'
    $urlRouterProvider.otherwise 'editor/theme/Monokai'

    $stateProvider
    .state 'editor', {
      url: '/editor'
      views: {
        '@': {
          templateUrl: 'template/editor.ng.html'
        }
        'gallery@editor': {
          controller: 'galleryController'
          templateUrl: 'template/gallery.ng.html'
        }
      }
    }

    .state 'editor.gallery', {
      url: '^/editor/theme/:theme'
      views: {
        'main': {
          templateUrl: 'template/main.ng.html'
          controller: 'editorController'
        }
      }
      resolve: Application.editorData
    }

    .state 'editor.url', {
      url: '^/editor/url/*theme'
      views: {
        'main': {
          templateUrl: 'template/main.ng.html'
          controller: 'editorController'
        }
      }
      resolve: Application.urlData
    }

    .state 'editor.local', {
      url: '^/editor/local/:theme'
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
