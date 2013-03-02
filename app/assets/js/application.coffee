#= require vendors/sugar-1.3.9.js
#= require vendors/xregexp.js
#= require vendors/jquery-1.9.0.js
#= require vendors/jquery.cookie.js
#= require vendors/jquery-ui-1.10.0.sortable.js
#= require vendors/FileSaver.js
#= require vendors/tinycolor.js
#= require vendors/angular-1.0.4.js
#= require vendors/bootstrap/bootstrap-dropdown.js
#= require vendors/bootstrap/bootstrap-tooltip.js

#= require_tree lib
#= require_tree directives
#= require_tree services
#= require_tree controllers


$ ->
  $("[data-toggle='tooltip']").tooltip()
  uploadBtn = $("#upload-btn")
  uploadInput = $("#files")
  uploadInput.mouseenter -> uploadBtn.addClass("hover")
  uploadInput.mouseleave -> uploadBtn.removeClass("hover")
  uploadInput.click ->
    uploadBtn.addClass("active")
    delayed = ->
      uploadBtn.removeClass("hover").removeClass("active")
    setTimeout(delayed,1200)
