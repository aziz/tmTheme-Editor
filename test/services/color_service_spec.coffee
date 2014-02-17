describe 'Service: Color', ->

  beforeEach(module('ThemeEditor'))

  it 'parses normal hex color', inject (Color) ->
    expect(Color.parse('#333333')).toBe('#333333')

  it 'parses hex color with alpha channel', inject (Color) ->
    expect(Color.parse('#333333cc')).toBe('rgba(51, 51, 51, 0.8)')
    expect(Color.parse('#33333300')).toBe('rgba(51, 51, 51, 0)')
    expect(Color.parse('#333333ff')).toBe('rgb(51, 51, 51)')

  it 'labels dark colors as dark and light colors as light', inject (Color) ->
    expect(Color.light_or_dark('#fff')).toBe('light')
    expect(Color.light_or_dark('#999')).toBe('light')
    expect(Color.light_or_dark('#000')).toBe('dark')
    expect(Color.light_or_dark('#666')).toBe('dark')

  it 'darkens/lightens colors properly', inject (Color) ->
    expect(Color.darken('#f00', 10)).toEqual('hsl(0, 100%, 40%)')
    expect(Color.darken('#f00', 30)).toEqual('hsl(0, 100%, 20%)')
    expect(Color.lighten('#f00', 10)).toEqual('hsl(0, 100%, 60%)')
    expect(Color.lighten('#f00', 30)).toEqual('hsl(0, 100%, 80%)')

  it 'detects colors correctly', inject (Color) ->
    expect(Color.is_color('not_color')).toBeFalsy()
    expect(Color.is_color('#22')).toBeFalsy()
    expect(Color.is_color('#a')).toBeFalsy()
    expect(Color.is_color('#aaa')).toBeTruthy()
    expect(Color.is_color('#aaaaaa')).toBeTruthy()
    expect(Color.is_color('#aaaaaaff')).toBeTruthy()

  xit 'brightness_contrast', ->
  xit 'invert, sepia, solarize', ->

