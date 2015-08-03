Application.factory "Theme",
['Color', 'GeneralKB', 'json_to_plist', 'plist_to_json',
 (Color,   GeneralKB,   json_to_plist,   plist_to_json) ->
  xml  = ''
  json = ''
  type = ''
  gcolors = []
  bg = {}
  fg = {}
  _border_color = null

  find_general_rules = (rules) ->
    rules.find((rule) -> rule.settings.lineHighlight) or rules[0]

  process = (data) ->
    try
      @xml = data
      @json = plist_to_json(data)
      @gcolors = []
      throw "can not covert to json" unless @json
      if @json && @json.settings
        general_rules = find_general_rules(@json.settings)
        for key, val of general_rules.settings
          defaults = GeneralKB[key] or {}
          extended = angular.extend({}, defaults, { name: key, color: val })
          @gcolors.push(extended)
        @bg = @gcolors.find((gc) -> gc.name == 'background')
        @fg = @gcolors.find((gc) -> gc.name == 'foreground')
        _border_color = null
        @border_color()
        @json.colorSpaceName = 'sRGB'
        @json.semanticClass = "theme.#{Color.light_or_dark(@bg.color)}.#{@json.name.underscore().replace(/[\(\)'&]/g, '')}"
    catch error
      return { error: error, msg: 'PARSE ERROR: could not parse your file!' }


  # TODO: should not be exposed, only used in save which should be part of this service
  update_general_colors = ->
    globals = find_general_rules(@json.settings)
    globals.settings = {}
    globals.settings[gc.name] = gc.color for gc in @gcolors

  addable_gcolors = ->
    return unless @gcolors
    known = Object.extended(GeneralKB).keys()
    current = (gc.name for gc in @gcolors)
    known.subtract(current)

  add_gcolor = (rule_name) ->
    rule = GeneralKB[rule_name]
    rule.color = Color.random() if rule.isColor
    @gcolors.push(rule)
    return

  remove_gcolor = (rule) ->
    return unless rule and rule.deletable
    @gcolors.remove(rule)
    return

  is_font_style = (fontStyle, rule) ->
    rule?.settings?.fontStyle?.indexOf(fontStyle) >= 0

  toggle_font_style = (fontStyle, rule) ->
    rule.settings = {} unless rule.settings
    rule.settings.fontStyle = '' unless rule.settings.fontStyle
    if @is_font_style(fontStyle, rule)
      rule.settings.fontStyle = rule.settings.fontStyle.replace(fontStyle, "")
      delete rule.settings['fontStyle'] if rule.settings.fontStyle.isBlank()
    else
      rule.settings.fontStyle += " #{fontStyle}"

  reset_color = (rule, attr) -> delete rule.settings[attr]

  selection_color = -> @gcolors?.find((gc) -> gc.name == 'selection')?.color
  line_highlight = -> @gcolors?.find((gc) -> gc.name == 'lineHighlight')?.color
  gutter_fg = -> @gcolors?.find((gc) -> gc.name == 'gutterForeground')?.color
  gutter_bg = -> @gcolors?.find((gc) -> gc.name == 'gutter')?.color

  border_color = ->
    return _border_color if _border_color
    # TODO: should not return style, should be a class name
    _border_color = if Color.light_or_dark(Color.parse(@bg.color)) == 'light' then 'rgba(0,0,0,.33)' else 'rgba(255,255,255,.33)'

  download = ->
    @update_general_colors()
    plist = json_to_plist(@json)
    blob = new Blob([plist], {type: 'text/plain'})
    saveAs blob, "#{@json.name}.tmTheme"

  to_plist = -> json_to_plist(@json)

  # Theme Stylesheet Generator ------------------------------------------

  css_scopes = ->
    styles = ''
    if @json and @json.settings
      for rule in @json.settings.compact()
        fg_color  = if rule?.settings?.foreground then Color.parse(rule.settings.foreground) else null
        bg_color  = if rule?.settings?.background then Color.parse(rule.settings.background) else null
        bold      = @is_font_style('bold', rule)
        italic    = @is_font_style('italic', rule)
        underline = @is_font_style('underline', rule)
        if rule.scope
          rules = rule.scope.split(',').map (r) -> r.trim().split(/\s+/).map((x) -> ".#{x}").join(' ')
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
    if @json && @json.settings && @bg.color
      gutter_bg = Color.parse(@gutter_bg()) || 'transparent'
      gutter_fg = Color.parse(@gutter_fg())
      unless gutter_fg
        bgcolor = Color.parse(@bg.color)
        gutter_fg =  if Color.light_or_dark(bgcolor) == 'light'
            Color.darken(bgcolor, 18)
          else
            Color.lighten(bgcolor, 18)
      style = ".preview pre .l:before { color: #{gutter_fg}; background-color: #{gutter_bg}; }"
    style

  css_selection = ->
    style = ''
    if @json && @json.settings
      style = """
        pre::selection { background: transparent }
        .preview pre *::selection { background: #{Color.parse(@selection_color())}; }
        .selected { background-color: #{Color.parse(@line_highlight())} }
      """
    style

  color_palette = ->
    colors = []
    if @json && @json.settings
      for rule in @json.settings.compact()
        if rule?.settings?.foreground
          colors.push Color.parse(rule.settings.foreground)
        if rule?.settings?.background
          colors.push Color.parse(rule.settings.background)

      for rule in @gcolors
        if rule.color and rule.color.startsWith("#")
          colors.push Color.parse(rule.color)

    palette = colors.unique().map((c) -> Color.tm_decode(c) )
    sorted = palette.sortBy((c) ->
      hsv = c.toHsv()
      hsv.h*100 + hsv.s*10 + hsv.v*1000 + (1-hsv.a)*1000000
    )
    formatted = sorted.map( (c) -> c.toRgbString() )
    formatted.unique()

  return {
    process
    download
    to_plist
    xml
    json
    type
    gcolors
    addable_gcolors
    add_gcolor
    remove_gcolor
    update_general_colors
    is_font_style
    toggle_font_style
    reset_color
    bg
    fg
    selection_color
    line_highlight
    gutter_fg
    gutter_bg
    border_color
    css_scopes
    css_gutter
    css_selection
    color_palette
  }
]
