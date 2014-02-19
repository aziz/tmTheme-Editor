
window.Application = angular.module('ThemeEditor', ['ngSanitize', 'ngCookies', 'ui.sortable', 'ui.bootstrap'])

Application.run ->
  window.requestFileSystem  = window.requestFileSystem || window.webkitRequestFileSystem
  window.BlobBuilder        = window.BlobBuilder || window.WebKitBlobBuilder
  window.FsErrorHandler = (e) -> console.error "Error [#{e.name}] - #{e.message}"

  $("#loading").remove() unless window.chrome
  enable_trasition = -> $('body').removeClass('transition-off')
  setTimeout(enable_trasition, 600)

  # <script src="https://cdn.firebase.com/v0/firebase.js"></script>
  # var dataRef = new Firebase("https://theme-editor.firebaseio.com");
  # dataRef.set("I am now writing data into Firebase!")



