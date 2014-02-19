Application.factory "HUDEffects", ['Theme', 'Color', (Theme, Color) ->
  hud = {}
  hud.visible  = false
  hud.colorize = false
  hud.apply_to_general = false

  original_colors = {}
  brightness = 0
  contrast   = 0
  hue        = 0
  saturation = 0
  lightness  = 0

  Object.defineProperty hud, "brightness", {
    get: ->  brightness
    set: (new_val) -> brightness = parseInt(new_val, 10)
  }

  Object.defineProperty hud, "contrast", {
    get: ->  contrast
    set: (new_val) -> contrast = parseInt(new_val, 10)
  }

  Object.defineProperty hud, "hue", {
    get: ->  hue
    set: (new_val) -> hue = parseInt(new_val, 10)
  }

  Object.defineProperty hud, "saturation", {
    get: ->  saturation
    set: (new_val) -> saturation = parseInt(new_val, 10)
  }

  Object.defineProperty hud, "lightness", {
    get: ->  lightness
    set: (new_val) -> lightness = parseInt(new_val, 10)
  }

  hud.toggle = ->
    if not @visible
      original_colors = angular.copy(Theme.json.settings)
    @visible = not @visible

  hud.hide = -> @visible = false

  hud.reset_changes = ->
    Theme.json.settings = angular.copy(original_colors)
    @brightness = 0
    @contrast   = 0
    @hue        = 0
    @saturation = 0
    @lightness  = 0

  # TODO rule.settings.foreground is not safe, should parse colors with color service
  hud.filter_colors = (filter) ->
    for rule in Theme.json.settings
      if rule.settings
        if rule.settings.foreground
          rule.settings.foreground = Color[filter](rule.settings.foreground)
        if rule.settings.background
          rule.settings.background = Color[filter](rule.settings.background)
    for rule in Theme.gcolors
      rule.color = Color[filter](rule.color)
    original_colors = angular.copy(Theme.json.settings)

  # TODO rule.settings.foreground is not safe, should parse colors with color service
  hud.update_brightness_contrast = (->
    for rule,i in original_colors
      if rule.scope && rule.settings
        if fg = rule.settings.foreground
          Theme.json.settings[i].settings.foreground = Color.brightness_contrast(fg, @brightness, @contrast)
        if bg = rule.settings.background
          Theme.json.settings[i].settings.background = Color.brightness_contrast(bg, @brightness, @contrast)
    if @apply_to_general
      for rule in Theme.gcolors
        rule.color = Color.brightness_contrast(rule.color, @brightness, @contrast)
  ).throttle(20)

  hud.update_hsl = (->
    for rule,i in original_colors
      if rule.scope && rule.settings
        if fg = rule.settings.foreground
          Theme.json.settings[i].settings.foreground = Color.change_hsl(fg, @hue, @saturation, @lightness, @colorize)
        if bg = rule.settings.background
          Theme.json.settings[i].settings.background = Color.change_hsl(bg, @hue, @saturation, @lightness, @colorize)
  ).throttle(10)

  return hud
]
