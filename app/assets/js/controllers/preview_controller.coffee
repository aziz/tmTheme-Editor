Application.controller "previewController", ['$scope', '$http', '$rootScope','throbber'], ($scope, $http, $rootScope, throbber) ->

  $scope.colorized = ''
  $scope.available_langs = [
    'CoffeeScript',
    'CSS',
    'HTML',
    'Java'
    'Javascript',
    'Python',
    'Ruby',
  ]
  $scope.current_lang = $.cookie('currnet_lang') || $scope.available_langs.first()
  $scope.set_lang = (lang) -> $scope.current_lang = lang

  $scope.$watch 'current_lang', (n,o) ->
      throbber.on(full_window: true)
      $http.get("/files/samples/pre-compiled/#{$scope.current_lang.toLowerCase()}.html").success (data) ->
        $.cookie('currnet_lang', $scope.current_lang)
        $scope.colorized = data
        throbber.off()

  # Custom Code
  $scope.custom_code = ""
  $scope.custom_code_editor_visible = false
