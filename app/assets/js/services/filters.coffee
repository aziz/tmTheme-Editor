Application.factory "removeExtensionFilter", [ ->
  (filename) ->
    filename.replace(/\.(hidden-)?[tT]m[Tt]heme/,"")
]
