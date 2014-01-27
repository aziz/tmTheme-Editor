window.Angular.filter "removeExtension", ->
  (filename) ->
    filename.replace(/\.[tT]m[Tt]heme/,"")
