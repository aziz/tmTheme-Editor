Application.factory "HUDEffects", ['Theme', 'Color', '$timeout', (Theme, Color, $timeout) ->
  hud = {}

  original_colors = {}
  original_gcolors = []
  brightness = 0
  contrast   = 0
  hue        = 0
  saturation = 0
  lightness  = 0
  processing = false

  # Sliders return a string while number inputs need integer.
  # That's why we need to define these smart properties with
  # getters and setters to always keep the values as integers
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

  hud.visible  = false
  hud.colorize = false
  hud.apply_to_general = false

  hud.toggle = ->
    if not @visible
      original_colors = angular.copy(Theme.json.settings)
      original_gcolors = angular.copy(Theme.gcolors)
    @visible = not @visible

  hud.hide = -> @visible = false

  hud.reset_changes = ->
    Theme.json.settings = angular.copy(original_colors)
    Theme.gcolors = angular.copy(original_gcolors)
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
      unless rule.name.endsWith("Options")
        rule.color = Color[filter](rule.color)
    # original_colors = angular.copy(Theme.json.settings)

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
    return
  ).throttle(25)

  hud.update_hsl = ( (alaki = "") ->
    if processing
      $timeout(@update_hsl("from timeout"), 15)
      return
    console.log "from timeout" if alaki.length > 0
    console.log "called"
    processing = true
    for rule,i in original_colors
      if rule.scope && rule.settings
        if fg = rule.settings.foreground
          Theme.json.settings[i].settings.foreground = Color.change_hsl(fg, @hue, @saturation, @lightness, @colorize)
        if bg = rule.settings.background
          Theme.json.settings[i].settings.background = Color.change_hsl(bg, @hue, @saturation, @lightness, @colorize)
    processing = false
    return
  ).throttle(25)

  return hud
]
