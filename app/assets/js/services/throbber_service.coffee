Angie.service "throbber", [], () ->

  element = $("#loading")
  throbber = {}

  throbber.on = -> element.show().addClass("show")

  throbber.off = -> element.removeClass("show").hide()

  return throbber