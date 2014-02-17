#= require vendors/sugar-1.3.9.js
#= require vendors/jquery-2.0.0.js
#= require vendors/jquery.scrollintoview.js
#= require vendors/jquery.cookie-1.3.1.js
#= require vendors/jquery-ui-1.10.4.sortable.js
#= require vendors/angular-1.2.12/angular.js
#= require vendors/angular-1.2.12/angular-sanitize.js
#= require vendors/sortable.js
#= require vendors/FileSaver-20130123.js
#= require vendors/tinycolor-0.9.14.js
#= require vendors/spin-1.3.js
#= require vendors/bootstrap/bootstrap-dropdown.js
#= require vendors/bootstrap/bootstrap-tooltip.js

#= require boot
#= require_tree directives
#= require_tree services
#= require_tree controllers


$ ->
  $("[data-toggle='tooltip']").tooltip()
  $("#loading").remove() unless window.chrome

  enable_trasition = -> $('body').removeClass('transition-off')
  setTimeout(enable_trasition, 600)


  # <script src="https://cdn.firebase.com/v0/firebase.js"></script>
  # var dataRef = new Firebase("https://theme-editor.firebaseio.com");
  # dataRef.set("I am now writing data into Firebase!")
