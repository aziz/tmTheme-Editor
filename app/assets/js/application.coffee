#= require vendors/sugar-1.3.9.js
#= require vendors/xregexp-3.0.0pre.js
#= require vendors/jquery-2.0.0.js
#= require vendors/jquery.cookie-1.3.1.js
#= require vendors/jquery-ui-1.10.2.sortable.js
#= require vendors/FileSaver-20130123.js
#= require vendors/tinycolor-0.9.14.js
#= require vendors/angular-1.1.4.js
#= require vendors/spin-1.3.js
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

  opts = {
    lines: 13, # The number of lines to draw
    length: 10, # The length of each line
    width: 10, # The line thickness
    radius: 31, # The radius of the inner circle
    corners: 0.9, # Corner roundness (0..1)
    rotate: 0, # The rotation offset
    direction: 1, # 1: clockwise, -1: counterclockwise
    color: '#fff', # #rgb or #rrggbb
    speed: 1.4, # Rounds per second
    trail: 31, # Afterglow percentage
    shadow: false, # Whether to render a shadow
    hwaccel: true, # Whether to use hardware acceleration
    className: 'spinner', # The CSS class to assign to the spinner
    zIndex: 2e9, # The z-index (defaults to 2000000000)
    top: 'auto', # Top position relative to parent in px
    left: 'auto' # Left position relative to parent in px
  }
  spinner = new Spinner(opts).spin($("#loading")[0])
