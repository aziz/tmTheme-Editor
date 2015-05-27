Application.factory "ThemeLoader",
['$http', '$q', '$window', 'FileManager',
( $http,   $q,   $window,   FileManager) ->

  themes_future = $q.defer()
  themes = $http.get("#{$window.API}/gallery.json")
  themes.success (data) ->
    for theme in data
      theme.color_type = if theme.light then 'light' else 'dark'
    themes_future.resolve(data)

  load = (theme) ->
    theme_promise = $q.defer()
    cached = FileManager.load(theme.url, 'http_cache')
    if cached
      theme_promise.resolve(cached)
    else
      http_get = $http.get("#{$window.API}/get_uri?uri=#{encodeURIComponent(theme.url)}")
      http_get.success (data) ->
        theme_promise.resolve(data)
        FileManager.save(theme.url, data, 'http_cache')
    theme_promise.promise

  return {
    themes: themes_future.promise
    load: load
  }
]
