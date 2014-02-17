Application.factory "removeExtensionFilter", [ ->
  (filename) ->
    filename.replace(/\.[tT]m[Tt]heme/,"")
]
