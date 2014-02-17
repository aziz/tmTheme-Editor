Application.factory "Color", [ ->
  color = {}
  clamp = (val) -> Math.min(1, Math.max(0, val))

  color.parse = (color) ->
    return null unless color && color.startsWith("#") && color.length >= 4
    if color.length > 7
      hex_color = color.to(7)
      rgba      = tinycolor(hex_color).toRgb()
      opacity   = parseInt(color.at(7,8).join(''), 16)/255
      rgba.a    = opacity
      new_rgba  = tinycolor(rgba)
      new_rgba.toRgbString()
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

  #-----------

  color.brightness_contrast = (color, brightness, contrast) ->
    rgb = tinycolor(color).toRgb()
    brightMul = 1 + Math.min(150, Math.max(-150, brightness)) / 150
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
    tinycolor(r: new_r, g: new_g, b: new_b)


  color.invert = (color) ->
    rgb = tinycolor(color).toRgb()
    rgb.r = 255 - rgb.r
    rgb.g = 255 - rgb.g
    rgb.b = 255 - rgb.b
    tinycolor(rgb)

  color.solarize = (color) ->
    rgb = tinycolor(color).toRgb()
    rgb.r = 255 - rgb.r  if rgb.r > 127
    rgb.g = 255 - rgb.g  if rgb.g > 127
    rgb.b = 255 - rgb.b  if rgb.b > 127
    tinycolor(rgb)

  color.sepia = (color) ->
    rgb = tinycolor(color).toRgb()
    r = (rgb.r * 0.393 + rgb.g * 0.769 + rgb.b * 0.189)
    g = (rgb.r * 0.349 + rgb.g * 0.686 + rgb.b * 0.168)
    b = (rgb.r * 0.272 + rgb.g * 0.534 + rgb.b * 0.131)
    r = 0  if r < 0
    r = 255  if r > 255
    g = 0  if g < 0
    g = 255  if g > 255
    b = 0  if b < 0
    b = 255  if b > 255
    tinycolor(r: r, g: g, b: b)

  return color

]
