Application.factory "ThemeLoader", ['$http'], ($http) ->

  themes = $http.get("/gallery.json")

  load   = (theme) -> $http.get("/get_uri?uri=#{encodeURIComponent(theme.url)}")

  return {
    themes: themes
    load: load
  }
