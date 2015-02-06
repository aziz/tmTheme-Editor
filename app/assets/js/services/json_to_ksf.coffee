Application.value "json_to_ksf", (json) ->
  
  console.log json
  colors = {}
  
  for k in json['settings']
    console.log k
    if k['settings']['foreground']?
      name = k['name'] or "global"
      do (name) ->
        if name is "global" then colors[name.toLowerCase()] = k['settings'] else colors[name.toLowerCase()] = "\"#{k['settings']['foreground']}\""
  
  console.log colors
  
  pattern = """
def hexToBGR(val):
    if type(val) == int:
        return val

    val = val.lstrip('#')
    if len(val) == 3:
        val += val

    r,g,b = int(val[:2], 16), int(val[2:4], 16), int(val[4:], 16)
    color = r+g*256+b*256*256
    return color

def parseColors():

    colors[\"attribute_name\"] = hexToBGR(#{colors['tag name']})
    colors[\"attributes\"] = colors[\"attribute_name\"]
    colors[\"attribute_value\"] = hexToBGR(#{colors['tag attribute']})
    colors[\"base_fore\"] = hexToBGR(\"#{colors['global']['foreground']}\")
    colors[\"base_back\"] = hexToBGR(\"#{colors['global']['background']}\")
    colors[\"classes\"] = hexToBGR(#{colors['class name']})
    colors[\"comment\"] = hexToBGR(#{colors['comment']})
    colors[\"constants\"] = hexToBGR(#{colors['built-in constant']})
    colors[\"functions\"] = hexToBGR(#{colors['functions']})
    colors[\"identifiers\"] = hexToBGR(#{colors['identifiers']})
    colors[\"keywords\"] = hexToBGR(#{colors['keywords']})
    colors[\"keywords2\"] = hexToBGR(#{colors['keywords']}) #FOR THE LOVE OF PYTHON
    colors[\"linenumber_back\"] = colors[\"base_fore\"]
    colors[\"linenumber_fore\"] = hexToBGR(#{colors['linenumbers']})
    colors[\"numbers\"] = hexToBGR(#{colors['numbers']})
    colors[\"operators\"] = hexToBGR(#{colors['keyword']})
    colors[\"regex\"] = colors[\"functions\"]
    colors[\"strings\"] = hexToBGR(#{colors['string']})
    colors[\"tags\"] = hexToBGR(#{colors['tag name']})
    colors[\"variables\"] = hexToBGR(#{colors['foreground']})
    colors[\"stdin\"] = hexToBGR(#{colors['background']})
    colors[\"stdout\"] = hexToBGR(colors[\"B0F\"])
    colors[\"stderr\"] = hexToBGR(colors[\"B0F\"])
    colors[\"css_ids\"] = hexToBGR(colors[\"B0F\"])
    colors[\"diff_add\"] = hexToBGR(#{colors['tag_attribute']})
    colors[\"diff_change\"] = hexToBGR(#{colors['strings']})
    colors[\"diff_delete\"] = hexToBGR(#{colors['keywords']})

    colors[\"red\"]       = colors[\"diff_delete\"]
    colors[\"orange\"]    = colors[\"functions\"]
    colors[\"yellow\"]    = colors[\"diff_change\"]
    colors[\"green\"]     = colors[\"diff_add\"]
    colors[\"teal\"]      = colors[\"variables\"]
    colors[\"blue\"]      = colors[\"numbers\"]
    colors[\"purple\"]    = colors[\"attributes\"]
    colors[\"themed\"]    = colors[\"strings\"]

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
                'fore': colors[\"attribute_name\"]
            },
            'attribute value': {
                'fore': colors[\"attribute_value\"]
            },
            'bracebad': {
                'fore': colors[\"base_fore\"]
            },
            'bracehighlight': {
                'fore': colors[\"base_fore\"],
                'back': colors[\"base_back\"]
            },
            'classes': {
                'fore': colors[\"classes\"]
            },
            'comments': {
                'fore': colors[\"comment\"],
                'italic': True
            },
            'control characters': {
                'fore': colors[\"constants\"] #NOT SURE, DUDE! JUST TRUST NATHAN, MAN, JUST TRUST HIM.
            },
            'default_fixed': {
                'back': colors[\"base_back\"],
                'eolfilled': 0,
                'face': 'Monaco, \"Source Code Pro\", Consolas, Inconsolata, \"DejaVu Sans Mono\", \"Bitstream Vera Sans Mono\", Menlo, Monaco, \"Courier New\", Courier, Monospace',
                'fore': colors[\"base_fore\"],
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
                'back': colors[\"base_back\"],
                'eolfilled': 0,
                'face': '\"DejaVu Sans\", \"Bitstream Vera Sans\", Helvetica, Tahoma, Verdana, sans-serif',
                'fore': colors[\"base_fore\"],
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
                'fore': colors[\"comment\"],
                'back': colors[\"base_back\"]
            },
            'functions': {
                'fore': colors[\"functions\"]
            },
            'identifiers': {
                'fore': colors[\"identifiers\"]
            },
            'indent guides': {
                'fore': colors[\"base_back\"]
            },
            'keywords': {
                'fore': colors[\"keywords\"]
            },
            'keywords2': {
                'fore': colors[\"keywords2\"]
            },
            'linenumbers': {
                'back': colors[\"linenumber_back\"],
                'fore': colors[\"linenumber_fore\"],
                'size': 10,
                'useFixed': True,
                'bold': False
            },
            'numbers': {
                'fore': colors[\"numbers\"]
            },
            'operators': {
                'fore': colors[\"operators\"]
            },
            'preprocessor': {
                'fore': colors[\"base_fore\"]
            },
            'regex': {
                'fore': colors[\"regex\"]
            },
            'stderr': {
                'fore': colors[\"stderr\"] #red
            },
            'stdin': {
                'fore': colors[\"stdin\"] #orange
            },
            'stdout': {
                'fore': colors[\"stdout\"] #wtf is it color?
            },
            'stringeol': {
                'back': colors[\"base_fore\"],
                'eolfilled': True
            },
            'strings': {
                'fore': colors[\"strings\"]
            },
            'tags': {
                'fore': colors[\"tags\"] #red
            },
            'variables': {
                'fore': colors[\"variables\"]
            }
        },

        'LanguageStyles': {
            'CSS': {
                'ids': {
                    'fore': colors[\"css_ids\"]
                },
                'values': {
                    'fore': colors[\"numbers\"]
                }
            },
            'Diff': {
                'additionline': {
                    'fore': colors[\"diff_add\"]
                },
                'chunkheader': {
                    'fore': colors[\"base_fore\"]
                },
                'deletionline': {
                    'fore': colors[\"diff_delete\"]
                },
                'diffline': {
                    'fore': colors[\"diff_change\"]
                },
                'fileline': {
                    'fore': colors[\"base_fore\"]
                }
            },
            'Errors': {
                'Error lines': {
                    'fore': colors[\"stderr\"],
                    'hotspot': 1,
                    'italic': 1
                }
            },
            'HTML': {
                'attributes': {
                    'fore': colors[\"attributes\"]
                },
                'cdata': {
                    'fore': colors[\"comment\"]
                },
                'cdata content': {
                    'fore': colors[\"base_fore\"]
                },
                'cdata tags': {
                    'fore': colors[\"base_fore\"]
                },
                'xpath attributes': {
                    'fore': colors[\"teal\"]
                }
            },
            'HTML5': {
                'attributes': {
                    'fore': colors[\"attributes\"]
                },
                'cdata': {
                    'fore': colors[\"comment\"]
                },
                'cdata content': {
                    'fore': colors[\"base_fore\"]
                },
                'cdata tags': {
                    'fore': colors[\"base_fore\"]
                },
                'xpath attributes': {
                    'fore': colors[\"teal\"]
                }
            },
            'XML': {
                'attributes': {
                    'fore': colors[\"attributes\"]
                },
                'cdata': {
                    'fore': colors[\"comment\"]
                },
                'cdata content': {
                    'fore': colors[\"base_fore\"]
                },
                'cdata tags': {
                    'fore': colors[\"base_fore\"]
                },
                'xpath attributes': {
                    'fore': colors[\"teal\"]
                }
            },
            'JavaScript': {
                'commentdockeyword': {
                    'fore': colors[\"comment\"]
                },
                'commentdockeyworderror': {
                    'fore': colors[\"stderr\"]
                },
                'globalclass': {
                    'fore': colors[\"classes\"]
                }
            },
            'PHP': {
                'commentdockeyword': {
                    'fore': colors[\"comment\"]
                },
                'commentdockeyworderror': {
                    'fore': colors[\"stderr\"]
                }
            }
        },

        'MiscLanguageSettings': {},

        'Colors': {
            'bookmarkColor': colors[\"base_back\"],
            'callingLineColor': colors[\"base_back\"],
            'caretFore': colors[\"comment\"],
            'caretLineBack': colors[\"base_back\"],
            'changeMarginDeleted': colors[\"diff_delete\"],
            'changeMarginInserted': colors[\"diff_add\"],
            'changeMarginReplaced': colors[\"diff_change\"],
            'currentLineColor': colors[\"base_back\"],
            'edgeColor': colors[\"base_back\"],
            'foldMarginColor': colors[\"base_back\"],
            'selBack': colors[\"base_back\"],
            'selFore': colors[\"base_fore\"],
            'whitespaceColor': colors[\"base_back\"]
        },

        'Indicators': {
            'collab_local_change': {
                'alpha': 0,
                'color': colors[\"green\"],
                'draw_underneath': False,
                'style': 5
            },
            'collab_remote_change': {
                'alpha': 255,
                'color': colors[\"yellow\"],
                'draw_underneath': True,
                'style': 7
            },
            'collab_remote_cursor_1': {
                'alpha': 255,
                'color': colors[\"yellow\"],
                'draw_underneath': True,
                'style': 6
            },
            'collab_remote_cursor_2': {
                'alpha': 255,
                'color': colors[\"orange\"],
                'draw_underneath': True,
                'style': 6
            },
            'collab_remote_cursor_3': {
                'alpha': 255,
                'color': colors[\"red\"],
                'draw_underneath': True,
                'style': 6
            },
            'collab_remote_cursor_4': {
                'alpha': 255,
                'color': colors[\"blue\"],
                'draw_underneath': True,
                'style': 6
            },
            'collab_remote_cursor_5': {
                'alpha': 255,
                'color': colors[\"teal\"],
                'draw_underneath': True,
                'style': 6
            },
            'find_highlighting': {
                'alpha': 100,
                'color': colors[\"base_back\"],
                'draw_underneath': True,
                'style': 7
            },
            'linter_error': {
                'alpha': 255,
                'color': colors[\"red\"],
                'draw_underneath': True,
                'style': 13
            },
            'linter_warning': {
                'alpha': 255,
                'color': colors[\"yellow\"],
                'draw_underneath': True,
                'style': 13
            },
            'multiple_caret_area': {
                'alpha': 255,
                'color': colors[\"blue\"],
                'draw_underneath': False,
                'style': 6
            },
            'soft_characters': {
                'alpha': 255,
                'color': colors[\"base_fore\"],
                'draw_underneath': False,
                'style': 0
            },
            'tabstop_current': {
                'alpha': 255,
                'color': colors[\"base_back\"],
                'draw_underneath': True,
                'style': 7
            },
            'tabstop_pending': {
                'alpha': 255,
                'color': colors[\"base_back\"],
                'draw_underneath': True,
                'style': 6
            },
            'tag_matching': {
                'alpha': 255,
                'color': colors[\"blue\"],
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