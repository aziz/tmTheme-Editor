Application.factory "FileManager", ['$q', ($q) ->

  _read_from_file_system = (file) ->
    deferred = $q.defer()
    reader = new FileReader()
    reader.readAsText(file)
    reader.onload = do (file) ->
      (e) ->
        localStorage.setItem("THEME/#{file.name}", e.target.result.trim())
        deferred.resolve(file.name)
    return deferred.promise

  list = angular.fromJson(localStorage.getItem("local_files")) or []
  load = (file_name) -> localStorage.getItem("THEME/#{file_name}")

  # Add returns an array of promises
  add = (files) ->
    file_names = for file in files
      # TODO: if name exisits and size is the same rename
      continue unless file.name.endsWith(/\.[tT]m[Tt]heme/)
      name = file.name
      @list.push({name: name})
      _read_from_file_system(file).then (file_name) -> file_name # TODO: then part is not needed

    localStorage.setItem("local_files", angular.toJson(@list))
    file_names

  add_from_memory = (file_name, content) ->
    @list.push({name: file_name})
    localStorage.setItem("local_files", angular.toJson(@list))
    @save(file_name, content)

  save = (file_name, content) ->
    localStorage.setItem("THEME/#{file_name}", content)

  remove = (file) ->
    @list.remove(file)
    localStorage.setItem("local_files", angular.toJson(@list))
    localStorage.removeItem("THEME/#{file.name}")

  {
    list:   list
    add:    add
    load:   load
    save:   save
    remove: remove
    add_from_memory: add_from_memory
  }
]
