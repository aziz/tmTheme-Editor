Application.factory "throbber", [ ->

  throbber = {}
  spinner_options = {
    lines: 13,            # The number of lines to draw
    length: 10,           # The length of each line
    width: 10,            # The line thickness
    radius: 31,           # The radius of the inner circle
    corners: 0.9,         # Corner roundness (0..1)
    rotate: 0,            # The rotation offset
    direction: 1,         # 1: clockwise, -1: counterclockwise
    color: '#fff',        # #rgb or #rrggbb
    speed: 1.4,           # Rounds per second
    trail: 31,            # Afterglow percentage
    shadow: false,        # Whether to render a shadow
    hwaccel: true,        # Whether to use hardware acceleration
    className: 'spinner', # The CSS class to assign to the spinner
    zIndex: 2e9,          # The z-index (defaults to 2000000000)
    top: 'auto',          # Top position relative to parent in px
    left: 'auto'          # Left position relative to parent in px
  }
  element = $("#loading")
  spinner = new Spinner(spinner_options).spin(element[0])
  loading_counter = 0

  throbber.on = (opt) ->
    loading_counter += 1
    # console.log "On #{loading_counter}"
    if opt && opt.full_window
      element.show().addClass("show full_window")
    else
      element.show().addClass("show")

  throbber.off = ->
    loading_counter -= 1 if loading_counter > 0
    # console.log "Off #{loading_counter}"
    element.removeClass("show").hide().removeClass("full_window") if loading_counter == 0

  throbber.visible = -> loading_counter > 0

  return throbber
]
