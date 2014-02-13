Application.controller 'previewController', ['$scope', '$http', '$rootScope','throbber', '$sce'], ($scope, $http, $rootScope, throbber, $sce) ->

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

  # Custom Code
  $scope.custom_code = localStorage.getItem('custom_code') || ''
  $scope.custom_code_editor_visible = false
  $scope.update_preview = ->
    throbber.on(full_window: true)
    $.cookie('currnet_lang', $scope.current_lang)
    if $scope.custom_code.length > 0
      localStorage.setItem('custom_code', $scope.custom_code)
      $http.post('/parse', {text: $scope.custom_code, syntax: $scope.current_lang}).success (data) ->
        $scope.colorized = $sce.trustAsHtml(data)
        $scope.custom_code_editor_visible = false
        throbber.off()
    else
      $http.get("/files/samples/pre-compiled/#{$scope.current_lang.toLowerCase()}.html").success (data) ->
        $scope.colorized = $sce.trustAsHtml(data)
        $scope.custom_code_editor_visible = false
        throbber.off()


  $scope.$watch 'current_lang', $scope.update_preview
