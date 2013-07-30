Application.controller "previewController", ['$scope', '$http', '$rootScope'], ($scope, $http, $rootScope) ->

  $scope.colorized = ''
  $scope.available_langs = ['Javascript', 'CoffeeScript', 'HTML', 'Ruby', 'Python']
  $scope.current_lang = $scope.available_langs.first()
  $scope.set_lang = (lang) -> $scope.current_lang = lang

  $scope.$watch 'current_lang', (n,o) ->
      $http.get("/files/samples/pre-compiled/#{$scope.current_lang.toLowerCase()}.html").success (data) ->
        $scope.colorized = data