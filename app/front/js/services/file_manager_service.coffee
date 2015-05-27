Application.factory "FileManager", ['$q', ($q) ->

  PREFIX = "LOCAL"

  _read_from_file_system = (file) ->
    deferred = $q.defer()
    reader = new FileReader()
    reader.readAsText(file)
    reader.onload = do (file) ->
      (e) ->
        localStorage.setItem("#{PREFIX}/#{file.name}", e.target.result.trim())
        deferred.resolve(file.name)
    return deferred.promise

  list = angular.fromJson(localStorage.getItem("local_files") || [])

  # Add returns an array of promises
  add = (files) ->
    file_names = for file in files
      # TODO: if name exisits and size is the same rename
      continue unless file.name.endsWith(/\.(hidden-)?[tT]m[Tt]heme/)
      name = file.name
      @list.push({name: name})
      _read_from_file_system(file).then (file_name) -> file_name

    localStorage.setItem("local_files", angular.toJson(@list))
    file_names

  add_from_memory = (file_name, content) ->
    @list.push({name: file_name})
    localStorage.setItem("local_files", angular.toJson(@list))
    @save(file_name, content)

  load = (file_name, prefix = PREFIX) ->
    localStorage.getItem("#{prefix}/#{file_name}")

  save = (file_name, content, prefix = PREFIX) ->
    localStorage.setItem("#{prefix}/#{file_name}", content)

  remove = (file, prefix = PREFIX) ->
    @list.remove(file)
    localStorage.setItem("local_files", angular.toJson(@list))
    localStorage.removeItem("#{prefix}/#{file.name}")

  return {
    list
    add
    load
    save
    remove
    add_from_memory
  }
]
