
add_filters = ->
  window.Angular.filter "removeExtension", ->
    (filename) ->
      filename.replace(/\.[tT]m[Tt]heme/,"")

if window.Angular
  add_filters()
else
  setTimeout(add_filters, 500)

