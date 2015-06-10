Application.factory "NewPopover", [ ->

  rule_pristine = {'name': '','scope': '  ','settings': {}}

  popover = {}
  popover.visible = false
  popover.rule = angular.copy(rule_pristine)
  popover.hide = -> @visible = false
  popover.show = ->
    @rule = angular.copy(rule_pristine)
    @visible = true

  return popover
]
