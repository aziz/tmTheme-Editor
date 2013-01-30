Angie.service "ThemeLoader", ['$http'], ($http) ->

  themes = $http.get("https://raw.github.com/aziz/tmTheme-Editor/master/gallery.json")

  load   = (theme) -> $http.get("/get_uri?uri=#{encodeURIComponent(theme.url)}")

  return {
    themes: themes
    load: load
  }