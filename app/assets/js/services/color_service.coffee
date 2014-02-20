Application.factory "Color", [ ->
  color = {}
  clamp = (val, min= 0, max=1) -> Math.min(max, Math.max(min, val))

  color.parse = (color) ->
    return null unless color and color[0] == "#" and color.length >= 4
    if color.length > 7
      hex     = color[0..6]
      rgba    = tinycolor(hex).toRgb()
      opacity = parseInt(color[7..8], 16)/255
      rgba.a  = opacity
      tinycolor(rgba).toRgbString()
    else
      color

  color.light_or_dark = (color) ->
    c   = tinycolor(color)
    d   = c.toRgb()
    yiq = ((d.r*299)+(d.g*587)+(d.b*114))/1000
    if yiq >= 128 then 'light' else 'dark'

  color.darken = (color, percent) ->
    c      = tinycolor(color)
    hsl    = c.toHsl()
    hsl.l -= percent/100
    hsl.l  = clamp(hsl.l)
    tinycolor(hsl).toHslString()

  color.lighten = (color, percent) ->
    c      = tinycolor(color)
    hsl    = c.toHsl()
    hsl.l += percent/100
    hsl.l  = clamp(hsl.l)
    tinycolor(hsl).toHslString()

  color.is_color = (color) -> if @parse(color) then true else false

  # Color Effects and Adjustments -----------------------

  color.brightness_contrast = (color, brightness, contrast) ->
    rgb = tinycolor(@parse(color)).toRgb()
    brightMul = 1 + Math.min(150, Math.max(-150, brightness)) / 150
    contrast = contrast/100.0
    contrast = Math.max(0, contrast + 1)
    unless contrast is 1
      mul = brightMul * contrast
      add = -contrast * 128 + 128
    else
      mul = brightMul
      add = 0
    r = rgb.r * mul + add
    g = rgb.g * mul + add
    b = rgb.b * mul + add
    if r > 255
      new_r = 255
    else if r < 0
      new_r = 0
    else
      new_r = r
    if g > 255
      new_g = 255
    else if g < 0
      new_g = 0
    else
      new_g = g
    if b > 255
      new_b = 255
    else if b < 0
      new_b = 0
    else
      new_b = b
    # TODO: alpha channel?
    tinycolor(r: new_r, g: new_g, b: new_b, a: rgb.a).toHex8String()

  color.change_hsl = (color, h_change, s_change, l_change, colorize) ->
    hsl = tinycolor(@parse(color)).toHsl()
    if colorize
      hsl.h = parseInt(h_change) + 180
    else
      hsl.h = hsl.h + parseInt(h_change)
      hsl.h += 360 if hsl.h < 0
      hsl.h -= 360 if hsl.h > 360
    hsl.s = clamp(hsl.s + parseInt(s_change)/100.0)
    hsl.l = clamp(hsl.l + parseInt(l_change)/100.0)
    tinycolor(hsl).toHex8String()

  color.invert = (color) ->
    rgb = tinycolor(@parse(color)).toRgb()
    rgb.r = 255 - rgb.r
    rgb.g = 255 - rgb.g
    rgb.b = 255 - rgb.b
    tinycolor(rgb).toHex8String()

  color.grayscale = (color) ->
    hsl = tinycolor(@parse(color)).toHsl()
    hsl.s = 0
    tinycolor(hsl).toHex8String()

  color.sepia = (color) ->
    rgb = tinycolor(@parse(color)).toRgb()
    r = (rgb.r * .393 + rgb.g * .769 + rgb.b * .189)
    g = (rgb.r * .349 + rgb.g * .686 + rgb.b * .168)
    b = (rgb.r * .272 + rgb.g * .534 + rgb.b * .131)
    r = 0  if r < 0
    r = 255  if r > 255
    g = 0  if g < 0
    g = 255  if g > 255
    b = 0  if b < 0
    b = 255  if b > 255
    tinycolor(r: r, g: g, b: b, a: rgb.a).toHex8String()

  # layered_with_opacity = (fg, bg, opacity) ->
  #   fg_rgb = tinycolor(fg).toRgb()
  #   bg_rgb = tinycolor(bg).toRgb()
  #   opacity = Math.max(opacity - 1 + bg.a, 0)
  #   fg_rgb.r = Math.round((bg_rgb.r - fg_rgb.r) * opacity + fg_rgb.r)
  #   fg_rgb.g = Math.round((bg_rgb.g - fg_rgb.g) * opacity + fg_rgb.g)
  #   fg_rgb.b = Math.round((bg_rgb.b - fg_rgb.b) * opacity + fg_rgb.b)
  #   tinycolor(fg_rgb).toHex8String()

  return color

]
