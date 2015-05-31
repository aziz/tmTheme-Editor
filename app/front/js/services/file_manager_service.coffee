Application.factory "FileManager", ['$q', ($q) ->

  PREFIX = "LOCAL"
  FM = {}

  _read_from_file_system = (file) ->
    deferred = $q.defer()
    reader = new FileReader()
    reader.readAsText(file)
    reader.onload = do (file) ->
      (e) ->
        localStorage.setItem("#{PREFIX}/#{file.name}", e.target.result.trim())
        deferred.resolve(file.name)
    return deferred.promise

  Object.defineProperty FM, "external_themes", {
    get: -> angular.fromJson(localStorage.getItem("external_themes") || [])
    set: (new_val) -> localStorage.setItem('external_themes', angular.toJson(new_val))
  }

  Object.defineProperty FM, "local_themes", {
    get: -> angular.fromJson(localStorage.getItem("local_themes") || [])
    set: (new_val) -> localStorage.setItem('local_themes', angular.toJson(new_val))
  }

  FM.add_external_theme = (theme_obj) ->
    return if @external_themes.find(theme_obj)
    @external_themes = @external_themes.add(theme_obj)

  # TODO: rename to add_local_theme
  # Add returns an array of promises
  FM.add_local_theme = (files) ->
    file_names = for file in files
      # TODO: if name exisits and size is the same rename
      continue unless file.name.endsWith(/\.(hidden-)?[tT]m[Tt]heme/)
      name = file.name
      @local_themes = @local_themes.add({name: name})
      _read_from_file_system(file).then (file_name) -> file_name

    file_names

  FM.add_from_memory = (file_name, content) ->
    @local_themes = @local_themes.add({name: file_name})
    @save(file_name, content)

  FM.load = (file_name, prefix = PREFIX) ->
    localStorage.getItem("#{prefix}/#{file_name}")

  FM.save = (file_name, content, prefix = PREFIX) ->
    localStorage.setItem("#{prefix}/#{file_name}", content)

  FM.remove = (file, prefix = PREFIX) ->
    @local_themes = @local_themes.remove((item) -> item.name == file.name)
    localStorage.removeItem("#{prefix}/#{file.name}")

  FM.remove_external_theme = (file) ->
    @external_themes = @external_themes.remove((item) -> item.url == file.url)
    localStorage.removeItem("cache_http/#{file.url}")

  FM.clear_cache = ->
    for key of localStorage
      localStorage.removeItem(key) if key.startsWith("cache")

  return FM
]
