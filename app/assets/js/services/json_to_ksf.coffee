Application.value "json_to_ksf", (json) ->
  
  #console.log json
  colors = {global: {}}
  
  for k in json['settings']
    if k['settings']['foreground']?
      name = k['name'] or "global"
      do (name) ->
        if name is "global"
          console.log k['settings']
          for i,v of k['settings']
            colors[name.toLowerCase()][i.toString().toLowerCase()] = "\"#{v}\""
        else if name is "invalid"
          colors[name.toLowerCase()] = "\"#{k['settings']['background']}\""
        else
          colors[name.toLowerCase()] = "\"#{k['settings']['foreground']}\""
  
  console.log colors
  
  pattern = """
def _(val):
    if type(val) == int:
        return val

    val = val.lstrip('#')
    if len(val) == 3:
        val += val

    r,g,b = int(val[:2], 16), int(val[2:4], 16), int(val[4:], 16)
    color = r+g*256+b*256*256
    return color

def parseColors():
  colors = {}
  colors['comment'] = _(#{colors['comment']})
  colors['string'] = _(#{colors['string']})
  colors['number'] = _(#{colors['number']})
  colors['regex'] = colors['number']
  colors['constant'] = _(#{colors['user-defined constant']})
  colors['variable'] = _(#{if colors['variable']? then colors['variable'] else colors['global']['foreground']})
  colors['keyword'] = _(#{colors['keyword']})
  colors['identifiers'] = _(#{colors['global']['foreground']})
  colors['function'] = colors['identifiers']
  colors['control_characters'] = _(#{colors['function argument']})
  colors['attr_name'] = _(#{colors['tag name']})
  colors['attr_value'] = _(#{colors['tag attribute']})
  colors['tag'] = colors['attr_name']
  colors['foreground'] = _(#{colors['global']['foreground']})
  colors['background'] = _(#{colors['global']['background']})
  colors['classes'] = _(#{colors['class name']})
  colors['l_back'] = colors['background']
  colors['l_fore'] = colors['comment']
  colors['current_line'] = _(#{colors['global']['linehighlight']})
  colors['operators'] = colors['foreground']
  colors['error'] = _(#{if colors['invalid']? then colors['invalid'] else colors['keyword']})
  colors['diff_add'] = _(#{colors['class name']})
  colors['diff_delete'] = _(#{colors['keyword']})
  colors['diff_change'] = _(#{colors['string']})
  colors['selection'] = _(#{colors['global']['selection']})
  return colors

def parseScheme(colors):
    return {

        'Version': 13,

        'Booleans': {
            'caretLineVisible': True,
            'preferFixed': True,
            'useSelFore': False
        },

        'CommonStyles': {
            'attribute name': {
                'fore': colors['attr_name']
            },
            'attribute value': {
                'fore': colors['attr_value']
            },
            'bracebad': {
                'fore': colors['foreground']
            },
            'bracehighlight': {
                'fore': colors['foreground'],
                'back': colors['background']
            },
            'classes': {
                'fore': colors['classes']
            },
            'comments': {
                'fore': colors['comment'],
                'italic': True
            },
            'control characters': {
                'fore': colors['control_characters']
            },
            'default_fixed': {
                'back': colors['background'],
                'eolfilled': 0,
                'face': 'Monaco, \"Source Code Pro\", Consolas, Inconsolata, \"DejaVu Sans Mono\", \"Bitstream Vera Sans Mono\", Menlo, Monaco, \"Courier New\", Courier, Monospace',
                'fore': colors['foreground'],
                'hotspot': 0,
                'italic': 0,
# #if PLATFORM == \"darwin\"
                'size': 13,
# #else
                'size': 11,
# #endif
                
                'useFixed': 1,
                'bold': 0,
                'lineSpacing': 2
            },
            'default_proportional': {
                'back': colors['background'],
                'eolfilled': 0,
                'face': '\"DejaVu Sans\", \"Bitstream Vera Sans\", Helvetica, Tahoma, Verdana, sans-serif',
                'fore': colors['foreground'],
                'hotspot': 0,
                'italic': 0,
# #if PLATFORM == \"darwin\"
                'size': 13,
# #else
                'size': 11,
# #endif
                'useFixed': 0,
                'bold': 0,
                'lineSpacing': 2
            },
            'fold markers': {
                'fore': colors['comment'],
                'back': colors['background']
            },
            'functions': {
                'fore': colors['function']
            },
            'identifiers': {
                'fore': colors['identifiers']
            },
            'indent guides': {
                'fore': colors['background']
            },
            'keywords': {
                'fore': colors['keyword']
            },
            'keywords2': {
                'fore': colors['keyword']
            },
            'linenumbers': {
                'back': colors['l_back'],
                'fore': colors['l_fore'],
                'size': 10,
                'useFixed': True,
                'bold': False
            },
            'numbers': {
                'fore': colors['number']
            },
            'operators': {
                'fore': colors['operators']
            },
            'preprocessor': {
                'fore': colors['foreground']
            },
            'regex': {
                'fore': colors['regex']
            },
            'stderr': {
                'fore': colors['error'] #red
            },
            'stdin': {
                'fore': colors['foreground'] #orange
            },
            'stdout': {
                'fore': colors['foreground'] #wtf is it color?
            },
            'stringeol': {
                'back': colors['foreground'],
                'eolfilled': True
            },
            'strings': {
                'fore': colors['string']
            },
            'tags': {
                'fore': colors['tag'] #red
            },
            'variables': {
                'fore': colors['variable']
            }
        },

        'LanguageStyles': {
            'CSS': {
                'ids': {
                    'fore': colors['keyword']
                },
                'values': {
                    'fore': colors['number']
                }
            },
            'Diff': {
                'additionline': {
                    'fore': colors['diff_add']
                },
                'chunkheader': {
                    'fore': colors['foreground']
                },
                'deletionline': {
                    'fore': colors['diff_delete']
                },
                'diffline': {
                    'fore': colors['diff_change']
                },
                'fileline': {
                    'fore': colors['foreground']
                }
            },
            'Errors': {
                'Error lines': {
                    'fore': colors['error'],
                    'hotspot': 1,
                    'italic': 1
                }
            },
            'HTML': {
                'attributes': {
                    'fore': colors['attr_name']
                },
                'cdata': {
                    'fore': colors['comment']
                },
                'cdata content': {
                    'fore': colors['foreground']
                },
                'cdata tags': {
                    'fore': colors['foreground']
                },
                'xpath attributes': {
                    'fore': colors['attr_value']
                }
            },
            'HTML5': {
                'attributes': {
                    'fore': colors['attr_name']
                },
                'cdata': {
                    'fore': colors['comment']
                },
                'cdata content': {
                    'fore': colors['foreground']
                },
                'cdata tags': {
                    'fore': colors['foreground']
                },
                'xpath attributes': {
                    'fore': colors['attr_value']
                }
            },
            'XML': {
                'attributes': {
                    'fore': colors['attr_name']
                },
                'cdata': {
                    'fore': colors['comment']
                },
                'cdata content': {
                    'fore': colors['foreground']
                },
                'cdata tags': {
                    'fore': colors['foreground']
                },
                'xpath attributes': {
                    'fore': colors['attr_value']
                }
            },
            'JavaScript': {
                'commentdockeyword': {
                    'fore': colors['comment']
                },
                'commentdockeyworderror': {
                    'fore': colors['error']
                },
                'globalclass': {
                    'fore': colors['classes']
                }
            },
            'PHP': {
                'commentdockeyword': {
                    'fore': colors['comment']
                },
                'commentdockeyworderror': {
                    'fore': colors['error']
                }
            }
        },

        'MiscLanguageSettings': {},

        'Colors': {
            'bookmarkColor': colors['background'],
            'callingLineColor': colors['background'],
            'caretFore': colors['comment'],
            'caretLineBack': colors['background'],
            'changeMarginDeleted': colors['diff_delete'],
            'changeMarginInserted': colors['diff_add'],
            'changeMarginReplaced': colors['diff_change'],
            'currentLineColor': colors['current_line'],
            'edgeColor': colors['background'],
            'foldMarginColor': colors['background'],
            'selBack': colors['selection'],
            'selFore': colors['foreground'],
            'whitespaceColor': colors['foreground']
        },

        'Indicators': {
            'find_highlighting': {
                'alpha': 100,
                'color': colors['background'],
                'draw_underneath': True,
                'style': 7
            },
            'linter_error': {
                'alpha': 255,
                'color': colors['error'],
                'draw_underneath': True,
                'style': 7
            },
            'linter_warning': {
                'alpha': 255,
                'color': colors['error'],
                'draw_underneath': True,
                'style': 13
            },
            'multiple_caret_area': {
                'alpha': 255,
                'color': colors['regex'],
                'draw_underneath': False,
                'style': 6
            },
            'soft_characters': {
                'alpha': 255,
                'color': colors['foreground'],
                'draw_underneath': False,
                'style': 0
            },
            'tabstop_current': {
                'alpha': 255,
                'color': colors['background'],
                'draw_underneath': True,
                'style': 7
            },
            'tabstop_pending': {
                'alpha': 255,
                'color': colors['background'],
                'draw_underneath': True,
                'style': 6
            },
            'tag_matching': {
                'alpha': 255,
                'color': colors['regex'],
                'draw_underneath': False,
                'style': 0
            }
        }

    }
colors = parseColors()
exports = parseScheme(colors)
"""
  #yep, ^-------- looks pretty scary.
  pattern