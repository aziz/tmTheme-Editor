Application.factory "ColorPicker", [ ->
  CP = {}

  CP.visible = false
  CP.current_tab = 'picker'
  CP.selector = null
  CP.rule = {}
  CP.active_sliders = {
    rgb: true
    hsl: false
    hsv: true
  }

  CP.pick = (rule, selector) ->
    CP.rule = rule
    CP.selector = selector
    CP.visible = true

  CP
]
