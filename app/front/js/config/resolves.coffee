Application.editorData = {
  current_theme: ['$stateParams', 'ThemeLoader', ($stateParams, ThemeLoader) ->
    theme = $stateParams.theme
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
  current_theme: ['$stateParams', 'ThemeLoader', ($stateParams, ThemeLoader) ->
    theme = $stateParams.theme
    return {
      data: ThemeLoader.load({ url: theme })
      name: theme.split('/').last().replace(/%20/g, ' ')
      url:  theme
      type: 'External URL'
    }
  ]
}

Application.localData = {
  current_theme: ['$stateParams', 'FileManager', '$q', ($stateParams, FileManager, $q) ->
    theme = $stateParams.theme
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

