Application.factory "ThemeLoader", ['$http', '$q', 'FileManager', ($http, $q, FileManager) ->

  themes_future = $q.defer()
  themes = $http.get("/gallery.json")
  themes.success (data) ->
    for theme in data
      theme.type = if theme.light then 'light' else 'dark'
    themes_future.resolve(data)

  load = (theme) ->
    theme_promise = $q.defer()
    cached = FileManager.load(theme.url, 'http_cache')
    if cached
      theme_promise.resolve(cached)
    else
      http_get = $http.get("/get_uri?uri=#{encodeURIComponent(theme.url)}")
      http_get.success (data) ->
        theme_promise.resolve(data)
        FileManager.save(theme.url, data, 'http_cache')
    theme_promise.promise

  return {
    themes: themes_future.promise
    load: load
  }
]
