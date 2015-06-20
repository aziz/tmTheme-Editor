Application.factory "GeneralColorsPopover", ['$timeout', ($timeout) ->

  popover = {}
  popover.visible = false
  popover.rule = {}
  popover.hide = -> @visible = false
  popover.show = (rule, rule_index) ->
    @rule = rule
    @visible = true
    $timeout => @set_position(rule_index)
    return

  popover.set_position = (rule_index) ->
    popover_el = $('#gc-popover')
    row  = $("#general-list .rule-#{rule_index}")
    winH = $(window).height()
    popover_el_height = popover_el.outerHeight()
    row_height = row.outerHeight()
    top  = row.offset().top

    if (winH - top) < popover_el_height/2
      popover_el.css({
        'top': 'auto'
        'left': ''
        'bottom': winH - top
      }).removeClass('on-bottom').addClass('on-top')
    else if top < popover_el_height/2
      popover_el.css({
        'left': ''
        'top': top + row_height
        'bottom': 'auto'
      }).removeClass('on-top').addClass('on-bottom')
    else
      popover_el.css({
        'top': top + (row_height/2) - (popover_el_height/2)
        'left': ''
        'bottom': 'auto'
      }).removeClass('on-top').removeClass('on-bottom')
    return true

  return popover

]
