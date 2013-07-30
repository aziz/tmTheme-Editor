Application.controller "previewController", ['$scope', '$http', '$rootScope','throbber'], ($scope, $http, $rootScope, throbber) ->

  $scope.colorized = ''
  $scope.available_langs = ['Javascript', 'CoffeeScript', 'HTML', 'CSS', 'Ruby', 'Python']
  $scope.current_lang = $scope.available_langs.first()
  $scope.set_lang = (lang) -> $scope.current_lang = lang

  $scope.$watch 'current_lang', (n,o) ->
      throbber.on()
      $http.get("/files/samples/pre-compiled/#{$scope.current_lang.toLowerCase()}.html").success (data) ->
        $scope.colorized = data
        throbber.off()