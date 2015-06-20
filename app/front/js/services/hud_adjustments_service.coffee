Application.factory "HUDEffects", ['Theme', 'Color', (Theme, Color) ->
  hud = {}

  original_colors = {}
  original_gcolors = []
  reset_colors = {}
  reset_gcolors = []

  hud.brightness = 0
  hud.contrast   = 0
  hud.hue        = 0
  hud.saturation = 0
  hud.lightness  = 0
  hud.visible  = false
  hud.colorize = false
  hud.apply_to_general = false

  hud.hide = -> @visible = false
  hud.toggle = ->
    if not @visible
      original_colors  = angular.copy(Theme.json.settings)
      original_gcolors = angular.copy(Theme.gcolors)
      reset_colors     = angular.copy(Theme.json.settings)
      reset_gcolors    = angular.copy(Theme.gcolors)
    @visible = not @visible

  hud.reset_changes = ->
    Theme.json.settings = angular.copy(reset_colors)
    Theme.gcolors = angular.copy(reset_gcolors)
    original_colors  = angular.copy(Theme.json.settings)
    original_gcolors = angular.copy(Theme.gcolors)
    @brightness = 0
    @contrast   = 0
    @hue        = 0
    @saturation = 0
    @lightness  = 0

  hud.filter_colors = (filter) ->
    for rule in Theme.json.settings
      if rule.settings
        if rule.settings.foreground
          rule.settings.foreground = Color[filter](rule.settings.foreground)
        if rule.settings.background
          rule.settings.background = Color[filter](rule.settings.background)
    for rule in Theme.gcolors
      continue unless rule.isColor
      rule.color = Color[filter](rule.color)
    original_colors  = angular.copy(Theme.json.settings)
    original_gcolors = angular.copy(Theme.gcolors)
    return

  hud.update_colors = (->
    for rule,i in original_colors
      if rule.scope && rule.settings
        if fg = rule.settings.foreground
          Theme.json.settings[i].settings.foreground = apply_color_adjustments(fg)
        if bg = rule.settings.background
          Theme.json.settings[i].settings.background = apply_color_adjustments(bg)
    if @apply_to_general
      for rule,i in original_gcolors
        continue unless rule.isColor
        Theme.gcolors[i].color = apply_color_adjustments(rule.color)
    return
  ).throttle(40)

  apply_color_adjustments = (color) ->
    ca1 = Color.change_hsl(color, hud.hue, hud.saturation, hud.lightness, hud.colorize)
    ca2 = Color.brightness_contrast(ca1, hud.brightness, hud.contrast)
    return ca2

  return hud
]
