Application.factory "Theme", ['Color', 'json_to_plist', 'plist_to_json', (Color, json_to_plist, plist_to_json) ->
  xml  = ''
  json = ''
  type = ''
  gcolors = []

  _border_color = null

  process = (data) ->
    try
      @xml = data
      @json = plist_to_json(data)
      @gcolors = []
      if @json && @json.settings
        for key, val of @json.settings[0].settings
          @gcolors.push({'name': key, 'color': val})
        _border_color = null
        @border_color()
        @json.colorSpaceName = 'sRGB'
        @json.semanticClass = "theme.#{Color.light_or_dark(@bg())}.#{@json.name.underscore().replace(/[\(\)'&]/g, '')}"
    catch error
      return { error: error, msg: 'PARSE ERROR: could not parse your file!' }

  # TODO: should not be exposed, only used in save which should be part of this service
  update_general_colors = ->
    globals = @json.settings[0]
    globals.settings = {}
    globals.settings[gc.name] = gc.color for gc in @gcolors

  is_font_style = (fontStyle, rule) ->
    rule.settings && rule.settings.fontStyle && rule.settings.fontStyle.indexOf(fontStyle) >= 0

  toggle_font_style = (fontStyle, rule) ->
    rule.settings = {} unless rule.settings
    rule.settings.fontStyle = '' unless rule.settings.fontStyle
    if @is_font_style(fontStyle, rule)
      rule.settings.fontStyle = rule.settings.fontStyle.replace(fontStyle, "")
      delete rule.settings['fontStyle'] if rule.settings.fontStyle.isBlank()
    else
      rule.settings.fontStyle += " #{fontStyle}"

  reset_color = (rule, attr) -> delete rule.settings[attr]

  bg = -> @gcolors.length > 0 && @gcolors.find((gc) -> gc.name == 'background').color
  fg = -> @gcolors.length > 0 && @gcolors.find((gc) -> gc.name == 'foreground').color
  selection_color = -> @gcolors.length > 0 && @gcolors.find((gc) -> gc.name == 'selection')?.color
  gutter_fg = -> @gcolors.length > 0 && @gcolors.find((gc) -> gc.name == 'gutterForeground')?.color
  gutter_bg = -> @gcolors.length > 0 && @gcolors.find((gc) -> gc.name == 'gutter')?.color

  border_color = ->
    return _border_color if _border_color
    # TODO: should not return style, should be a class name
    _border_color = if Color.light_or_dark(Color.parse(@bg())) == 'light' then 'rgba(0,0,0,.33)' else 'rgba(255,255,255,.33)'

  download = ->
    @update_general_colors()
    plist = json_to_plist(@json)
    blob = new Blob([plist], {type: 'text/plain'})
    saveAs blob, "#{@json.name}.tmTheme"

  to_plist = -> json_to_plist(@json)

  # Theme Stylesheet Generator ------------------------------------------

  css_scopes = ->
    styles = ''
    if @json && @json.settings
      for rule in @json.settings.compact()
        fg_color  = if rule?.settings?.foreground then Color.parse(rule.settings.foreground) else null
        bg_color  = if rule?.settings?.background then Color.parse(rule.settings.background) else null
        bold      = @is_font_style('bold', rule)
        italic    = @is_font_style('italic', rule)
        underline = @is_font_style('underline', rule)
        if rule.scope
          rules = rule.scope.split(',').map (r) -> r.trim().split(' ').map((x) -> ".#{x}").join(' ')
          rules.each (r) ->
            styles += "#{r}{"
            styles += "color:#{fg_color};" if fg_color
            styles += "background-color:#{bg_color};" if bg_color
            styles += "font-weight:bold;" if bold
            styles += "font-style:italic;" if italic
            styles += "text-decoration:underline;" if underline
            styles += "}\n"
    styles

  css_gutter = ->
    style = ''
    if @json && @json.settings && @bg()
      bgcolor = Color.parse(@bg())
      if Color.light_or_dark(bgcolor) == 'light'
        gutter_fg = Color.parse(@gutter_fg()) || Color.darken(bgcolor, 18)
        gutter_bg = Color.parse(@gutter_bg()) || Color.darken(bgcolor, 3)
      else
        gutter_fg = Color.parse(@gutter_fg()) || Color.lighten(bgcolor, 18)
        gutter_bg = Color.parse(@gutter_bg()) || Color.lighten(bgcolor, 3)
      style = ".preview pre .l:before { color: #{gutter_fg}; background-color: #{gutter_bg}; }"
    style

  css_selection = ->
    style = ''
    if @json && @json.settings
      style += "pre::selection {background:transparent}.preview pre *::selection {background:"
      style += "#{Color.parse(@selection_color())} }"
    style

  return {
    process
    download
    to_plist
    xml
    json
    type
    gcolors
    update_general_colors
    is_font_style
    toggle_font_style
    reset_color
    bg
    fg
    selection_color
    gutter_fg
    gutter_bg
    border_color
    css_scopes
    css_gutter
    css_selection
  }
]
