Application.factory "Theme", ['Color', 'json_to_plist', 'plist_to_json', (Color, json_to_plist, plist_to_json) ->
  theme = {}

  theme.xml  = ''
  theme.json = ''
  theme.type = ''
  theme.gcolors = []

  border_color = null

  theme.process = (data) ->
    @xml = data
    @json = plist_to_json(data)
    @gcolors = []
    if @json && @json.settings
      for key, val of @json.settings[0].settings
        @gcolors.push({'name': key, 'color': val})
      border_color = null
      @border_color()
      @json.colorSpaceName = 'sRGB'
      @json.semanticClass = "theme.#{Color.light_or_dark(@bg())}.#{@json.name.underscore().replace(/[\(\)'&]/g, '')}"

  theme.update_general_colors = ->
    globals = @json.settings[0]
    globals.settings = {}
    globals.settings[gc.name] = gc.color for gc in @gcolors

  theme.is_font_style = (fontStyle, rule) ->
    rule.settings && rule.settings.fontStyle && rule.settings.fontStyle.indexOf(fontStyle) >= 0

  theme.toggle_font_style = (fontStyle, rule) ->
    rule.settings = {} unless rule.settings
    rule.settings.fontStyle = '' unless rule.settings.fontStyle
    if @is_font_style(fontStyle, rule)
      rule.settings.fontStyle = rule.settings.fontStyle.replace(fontStyle, "")
      delete rule.settings['fontStyle'] if rule.settings.fontStyle.isBlank()
    else
      rule.settings.fontStyle += " #{fontStyle}"

  theme.reset_color = (rule, attr) -> delete rule.settings[attr]

  theme.bg = -> @gcolors.length > 0 && @gcolors.find((gc) -> gc.name == 'background').color
  theme.fg = -> @gcolors.length > 0 && @gcolors.find((gc) -> gc.name == 'foreground').color
  theme.selection_color = -> @gcolors.length > 0 && @gcolors.find((gc) -> gc.name == 'selection')?.color
  theme.gutter_fg = -> @gcolors.length > 0 && @gcolors.find((gc) -> gc.name == 'gutterForeground')?.color

  theme.border_color = ->
    return border_color if border_color
    border_color = if Color.light_or_dark(Color.parse(@bg())) == 'light' then 'rgba(0,0,0,.33)' else 'rgba(255,255,255,.33)'

  # Theme Stylesheet Generator ------------------------------------------

  theme.css_scopes = (->
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
  ).throttle(50)

  theme.css_gutter = (->
    style = ''
    if @json && @json.settings && @bg()
      bgcolor = Color.parse(@bg())
      if Color.light_or_dark(bgcolor) == 'light'
        style = ".preview pre:before { background-color: #{Color.darken(bgcolor, 2)}; }\n"
        gutter_foreground = Color.parse(@gutter_fg()) || Color.darken(bgcolor, 18)
        style += ".preview pre .l:before { color: #{gutter_foreground}; }"
      else
        style = ".preview pre:before { background-color: #{Color.lighten(bgcolor, 2)}; }\n"
        gutter_foreground = Color.parse(@gutter_fg()) || Color.lighten(bgcolor, 12)
        style += ".preview pre .l:before { color: #{gutter_foreground}; }"
    style
  ).throttle(50)

  theme.css_selection = (->
    style = ''
    if @json && @json.settings
      style += "pre::selection {background:transparent}.preview pre *::selection {background:"
      style += "#{Color.parse(@selection_color())} }"
    style
  ).throttle(50)

  theme.download = ->
    @update_general_colors()
    plist = json_to_plist(@json)
    blob = new Blob([plist], {type: 'text/plain'})
    saveAs blob, "#{@json.name}.tmTheme"


  for own k,v of theme
    if angular.isFunction(v)
      theme[k] = v.monitor(theme)

  theme.$report = ->
    table = for own k,v of theme
      if k[0] != "$" and angular.isFunction(v)
        { name: k, calls: v.calls_counter, time: v.last_call_time }
    console.table table

  return theme
]
