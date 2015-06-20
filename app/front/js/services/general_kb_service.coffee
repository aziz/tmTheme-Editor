Application.factory 'GeneralKB', [ ->
  background:
    deletable: false
    isColor: true
    name: 'background'
    color: '#FFFFFF'
    description: 'Backgound color of the view.'
  foreground:
    deletable: false
    isColor: true
    name: 'foreground'
    color: '#FFFFFF'
    description: 'Foreground color for the view.'
  caret:
    deletable: false
    isColor: true
    name: 'caret'
    color: '#FFFFFF'
    description: 'Color of the caret.'
  lineHighlight:
    deletable: false
    isColor: true
    name: 'lineHighlight'
    color: '#FFFFFF'
    description: 'Background color of the line the caret is in. Only used when the you enable it in your setting.'
  invisibles:
    deletable: false
    isColor: true
    name: 'invisibles'
    color: '#FFFFFF'
    description: 'Color of the invisible characters (e.g. carriage return or tab), in case you decide to make them visible.'
  selection:
    deletable: false
    isColor: true
    name: 'selection'
    color: '#FFFFFF'
    description: 'Color of the selection regions.'
  selectionBorder:
    deletable: true
    isColor: true
    name: 'selectionBorder'
    color: '#FFFFFF'
    description: 'Color of the selection regions’ border.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  selectionForeground:
    deletable: true
    isColor: true
    name: 'selectionForeground'
    color: '#FFFFFF'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  selectionBackground:
    deletable: true
    isColor: true
    name: 'selectionBackground'
    color: '#FFFFFF'
    description: 'Background color of the selection regions.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  inactiveSelection:
    deletable: true
    isColor: true
    name: 'inactiveSelection'
    color: '#FFFFFF'
    description: 'Color of inactive selections (inactive view).'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  findHighlight:
    deletable: true
    isColor: true
    name: 'findHighlight'
    color: '#FFFFFF'
    description: 'Background color of regions matching the current search.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  findHighlightForeground:
    deletable: true
    isColor: true
    name: 'findHighlightForeground'
    color: '#FFFFFF'
    description: 'Background color of regions matching the current search.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  highlight:
    deletable: true
    isColor: true
    name: 'highlight'
    color: '#FFFFFF'
    description: 'Background color for regions added via <code>sublime.add_regions()</code> with the <code>sublime.DRAW_OUTLINED</code> flag added.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  highlightForeground:
    deletable: true
    isColor: true
    name: 'highlightForeground'
    color: '#FFFFFF'
    description: 'Foreground color for regions added via <code>sublime.add_regions()</code> with the <code>sublime.DRAW_OUTLINED</code> flag added.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  guide:
    deletable: true
    isColor: true
    name: 'guide'
    color: '#FFFFFF'
    description: 'Color of the guides displayed to indicate nesting levels.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  activeGuide:
    deletable: true
    isColor: true
    name: 'activeGuide'
    color: '#FFFFFF'
    description: 'Color of the guide lined up with the caret. Only applied if the <code>indent_guide_options</code> setting is set to <code>draw_active</code>.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  stackGuide:
    deletable: true
    isColor: true
    name: 'stackGuide'
    color: '#FFFFFF'
    description: 'Color of the current guide’s parent guide level. Only used if the <code>indent_guide_options</code> setting is set to <code>draw_active</code>.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  gutterForeground:
    deletable: true
    isColor: true
    name: 'gutterForeground'
    color: '#FFFFFF'
    description: 'Foreground color of the gutter.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  gutter:
    deletable: true
    isColor: true
    name: 'gutter'
    color: '#FFFFFF'
    description: 'Background color of the gutter.'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  bracketsForeground:
    description: 'Foreground color of the brackets when the caret is next to a bracket. Only applied when the <code>match_brackets</code> setting is set to <code>true</code>.'
    deletable: true
    isColor: true
    name: 'bracketsForeground'
    color: '#FFFFFF'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  bracketsOptions:
    description: "Controls certain options when the caret is next to a bracket. Only applied when the <code>match_brackets</code> setting is set to <code>true</code>. Options: <code>underline</code>, <code>stippled_underline</code>, <code>squiggly_underline</code>. <code>underline</code> indicates the text should be drawn using the given color, not just the underline."
    deletable: true
    isColor: false
    name: 'bracketsOptions'
    color: 'underline'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  bracketContentsForeground:
    description: 'Color of bracketed sections of text when the caret is in a bracketed section. Only applied when the <code>match_brackets</code> setting is set to <code>true</code>.'
    deletable: true
    isColor: true
    name: 'bracketContentsForeground'
    color: '#FFFFFF'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  bracketContentsOptions:
    description: "Controls certain options when the caret is in a bracket section. Only applied when the <code>match_brackets</code> setting is set to <code>true</code>. Options: <code>underline</code>, <code>stippled_underline</code>, <code>squiggly_underline</code>. The <code>underline</code> option indicates that the text should be drawn using the given color, not just the underline."
    deletable: true
    isColor: false
    name: 'bracketContentsOptions'
    color: 'underline'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  tagsOptions:
    description: "Controls certain options when the caret is next to a tag. Only applied when the <code>match_tags</code> setting is set to <code>true</code>. Options: <code>underline</code>, <code>stippled_underline</code>, <code>squiggly_underline</code>. <code>underline</code> indicates the text should be drawn using the given color, not just the underline."
    deletable: true
    isColor: false
    name: 'tagsOptions'
    color: 'underline'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  tagsForeground:
    description: 'Color of tags when the caret is next to a tag. Only used when the <code>match_tags</code> setting is set to <code>true</code>.'
    deletable: true
    isColor: true
    name: 'tagsForeground'
    color: '#FFFFFF'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  shadow:
    description: 'Color of the shadow effect when the buffer is scrolled.'
    deletable: true
    isColor: true
    name: 'shadow'
    color: '#FFFFFF'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
  shadowWidth:
    description: 'Width of the shadow effect when the buffer is scrolled.. Shoud be between 0 and 32.'
    deletable: true
    isColor: false
    name: 'shadowWidth'
    color: '0'
    editor_support:
        text: 'SublimeText only'
        editors: ['st']
]
