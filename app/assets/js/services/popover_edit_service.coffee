Application.factory "EditPopover", [ ->

  popover_el = $('#edit-popover')

  popover = {}
  popover.visible = false
  popover.rule = {}

  popover.hide = -> @visible = false

  popover.show = (rule, rule_index) ->
    @rule = rule
    @visible = true
    @set_position(rule_index)
    # TODO
    # $scope.new_popover_visible = false
    return

  popover.set_position = (rule_index) ->
    row  = $("#scope-lists .rule-#{rule_index}")
    top  = row.offset().top
    winH = $(window).height()

    if (winH - top) < 160
      popover_el.css({
        'top': 'auto'
        'left': ''
        'bottom': winH - top
      }).removeClass('on-bottom').addClass('on-top')
    else if top < 160
      popover_el.css({
        'left': ''
        'top': top + row.outerHeight()
        'bottom': 'auto'
      }).removeClass('on-top').addClass('on-bottom')
    else
      popover_el.css({
        'top': top + (row.outerHeight()/2) - 140
        'left': ''
        'bottom': 'auto'
      }).removeClass('on-top').removeClass('on-bottom')

    return true

  return popover

]
