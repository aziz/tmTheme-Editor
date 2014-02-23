Application.directive "dropZone", ["FileManager", "$location", "$q", (FileManager, $location, $q) ->
  restrict: "A"
  link: (scope, element, attrs) ->

    handleFileDrop = (e) ->
      e.stopPropagation()
      e.preventDefault()
      files = e.originalEvent.dataTransfer.files
      local_files = FileManager.add(files)
      # update the location path to the last file
      $q.all(local_files).then (names) ->
        $location.path("/local/#{names.last()}")

    handleDragOver = (e) ->
      e.stopPropagation()
      e.preventDefault()
      e.originalEvent.dataTransfer.dropEffect = 'copy'

    element.on 'dragover', handleDragOver
    element.on 'drop', handleFileDrop
    return
]
