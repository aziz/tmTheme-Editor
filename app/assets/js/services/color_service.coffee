Application.service "Color", [], () ->
  color = {}
  clamp = (val) -> Math.min(1, Math.max(0, val))

  color.parse = (color) ->
    if color && color.length > 7
      hex_color = color.to(7)
      rgba      = tinycolor(hex_color).toRgb()
      opacity   = parseInt(color.at(7,8).join(''), 16)/256
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

  return color
