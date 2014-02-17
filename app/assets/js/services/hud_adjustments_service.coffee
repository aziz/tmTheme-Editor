Application.factory "HUDEffects", ['Theme', 'Color', (Theme, Color) ->
  hud = {}
  original_colors = {}

  hud.visible = false
  hud.brightness = 0
  hud.saturation = 0

  hud.toggle = ->
    if not @visible
      original_colors = angular.copy(Theme.json.settings)
    @visible = not @visible

  hud.hide = -> @visible = false

  hud.reset_changes = ->
    Theme.json.settings = angular.copy(original_colors)
    @brightness = 0
    @saturation = 0

  # TODO rule.settings.foreground is not safe, should parse colors with color service
  hud.filter_colors = (filter) ->
    for rule in Theme.json.settings
      if rule.settings
        if rule.settings.foreground
          rule.settings.foreground = Color[filter](rule.settings.foreground).toHexString()
        if rule.settings.background
          rule.settings.background = Color[filter](rule.settings.background).toHexString()
    for rule in Theme.gcolors
      rule.color = Color[filter](rule.color).toHexString()
    original_colors = angular.copy(Theme.json.settings)

  # TODO rule.settings.foreground is not safe, should parse colors with color service
  hud.update_colors = (->
    for rule,i in original_colors
      if rule.scope && rule.settings
        if rule.settings.foreground
          Theme.json.settings[i].settings.foreground = Color.brightness_contrast( rule.settings.foreground, @brightness, @saturation/100 ).toHexString()
        if rule.settings.background
          Theme.json.settings[i].settings.background = Color.brightness_contrast( rule.settings.background, @brightness, @saturation/100.0 ).toHexString()

  ).throttle(20)

  return hud
]
