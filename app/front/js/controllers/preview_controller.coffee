Application.controller 'previewController',
['$scope', '$http', 'throbber', 'FileManager', '$window', '$q', '$sce',
( $scope,   $http,   throbber,   FileManager,   $window,   $q,   $sce ) ->

  $scope.colorized = ''
  $scope.available_langs = [
    'CoffeeScript',
    'CSS',
    'HTML',
    'Java'
    'Javascript',
    'Latex',
    'Perl',
    'PHP',
    'Python',
    'Ruby',
  ]
  $scope.current_lang = $.cookie("preview_lang") || $scope.available_langs[0]
  $scope.set_lang = (lang) -> $scope.current_lang = lang

  # Custom Code
  $scope.custom_code = localStorage.getItem('custom_code') || ''
  $scope.custom_code_editor_visible = false
  $scope.update_preview = ->
    throbber.on(full_window: true)
    $.cookie("preview_lang", $scope.current_lang)
    defered_code = $q.defer()
    if $scope.custom_code.length > 0
      localStorage.setItem('custom_code', $scope.custom_code)
      $http.post("#{$window.API}/parse", {text: $scope.custom_code, syntax: $scope.current_lang}).success (data) ->
        defered_code.resolve(data)
    else
      localStorage.removeItem('custom_code')
      lang = $scope.current_lang.toLowerCase()
      cached = FileManager.load(lang , 'sample_cache')
      if cached
        defered_code.resolve(cached)
      else
        $http.get("#{$window.API}/files/samples/pre-compiled/#{$scope.current_lang.toLowerCase()}.html").success (data) ->
          defered_code.resolve(data)
          FileManager.save(lang, data, 'sample_cache')

    defered_code.promise.then (data) ->
      root_scopes = $("<div>#{data}</div>").find("span.l").map((x,item) -> $(item).attr("class").replace(/^l\s/, "").replace(/l-\d+ /, ""))
      root_scope = Array.prototype.unique.call(root_scopes)
      console.log "Warning: more than one root scope found for this source code" if root_scope.length > 1
      $scope.root_scope = root_scope[0]
      $scope.colorized = $sce.trustAsHtml(data)
      $scope.custom_code_editor_visible = false
      throbber.off()

  $scope.$watch 'current_lang', $scope.update_preview

]
