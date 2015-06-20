Application.factory 'GeneralKB', [ ->
  background:
    deletable: false
    isColor: true
    name: 'background'
    color: '#FFFFFF'
  foreground:
    deletable: false
    isColor: true
    name: 'foreground'
    color: '#FFFFFF'
  caret:
    deletable: false
    isColor: true
    name: 'caret'
    color: '#FFFFFF'
  lineHighlight:
    deletable: false
    isColor: true
    name: 'lineHighlight'
    color: '#FFFFFF'
  invisibles:
    deletable: false
    isColor: true
    name: 'invisibles'
    color: '#FFFFFF'
  selection:
    deletable: false
    isColor: true
    name: 'selection'
    color: '#FFFFFF'
  selectionBorder:
    deletable: true
    isColor: true
    name: 'selectionBorder'
    color: '#FFFFFF'
  selectionForeground:
    deletable: true
    isColor: true
    name: 'selectionForeground'
    color: '#FFFFFF'
  selectionBackground:
    deletable: true
    isColor: true
    name: 'selectionBackground'
    color: '#FFFFFF'
  inactiveSelection:
    deletable: true
    isColor: true
    name: 'inactiveSelection'
    color: '#FFFFFF'
  findHighlight:
    deletable: true
    isColor: true
    name: 'findHighlight'
    color: '#FFFFFF'
  findHighlightForeground:
    deletable: true
    isColor: true
    name: 'findHighlightForeground'
    color: '#FFFFFF'
  highlight:
    deletable: true
    isColor: true
    name: 'highlight'
    color: '#FFFFFF'
  highlightForeground:
    deletable: true
    isColor: true
    name: 'highlightForeground'
    color: '#FFFFFF'
  guide:
    deletable: true
    isColor: true
    name: 'guide'
    color: '#FFFFFF'
  activeGuide:
    deletable: true
    isColor: true
    name: 'activeGuide'
    color: '#FFFFFF'
  stackGuide:
    deletable: true
    isColor: true
    name: 'stackGuide'
    color: '#FFFFFF'
  gutterForeground:
    deletable: true
    isColor: true
    name: 'gutterForeground'
    color: '#FFFFFF'
  gutter:
    deletable: true
    isColor: true
    name: 'gutter'
    color: '#FFFFFF'
  bracketsForeground:
    description: 'The color that is used to highlight matching brackets when the cursor is on the brackets.'
    deletable: true
    isColor: true
    name: 'bracketsForeground'
    color: '#FFFFFF'
  bracketsOptions:
    description: "Defines how to highlight matching brackets when the cursor is on one of the brackets. values can be combinations of 'foreground', 'underline', 'stippled_underline'."
    deletable: true
    isColor: false
    name: 'bracketsOptions'
    color: ''
  bracketContentsForeground:
    description: 'color that is used to highlight matching brackets when the cursor is between matching brackets'
    deletable: true
    isColor: true
    name: 'bracketContentsOptions'
    color: '#FFFFFF'
  bracketContentsOptions:
    description: "defines how to highlight matching brackets when the cursor is between the matching brackets. values can be combinations of 'foreground', 'underline', 'stippled_underline'."
    deletable: true
    isColor: false
    name: 'bracketContentsOptions'
    color: ''
  tagsOptions:
    description: "how to highlight matching tags in html/xml. values are 'foreground', 'underline', 'stippled_underline'"
    deletable: true
    isColor: false
    name: 'tagsOptions'
    color: ''
  tagsForeground:
    description: 'color of the UI element used to highlight matching tags'
    deletable: true
    isColor: true
    name: 'tagsForeground'
    color: '#FFFFFF'
  shadow:
    description: 'Color of the window shadow on the sides when it gets horizontal scroll.'
    deletable: true
    isColor: true
    name: 'shadow'
    color: '#FFFFFF'
  shadowWidth:
    description: 'width of the window shadow on the sides when it gets horizontal scroll. Shoud be between 0 and 32.'
    deletable: true
    isColor: false
    name: 'shadowWidth'
    color: '0'
]
