describe 'Filters', ->

  beforeEach(module('ThemeEditor'))

  describe 'filter: removeExtension', ->
    it 'removes extension from theme\'s file name', inject (removeExtensionFilter) ->
      expect(removeExtensionFilter("theme.tmTheme")).toEqual("theme")
      expect(removeExtensionFilter("theme2.tmtheme")).toEqual("theme2")

