Application.factory "Editor", [ ->

  Gallery = {}
  Gallery.visible = angular.fromJson($.cookie("gallery_visible") || false)
  Gallery.filter = {name: ''}
  Gallery.toggle = ->
    $('body').removeClass('transition-off')
    Gallery.visible = if Gallery.visible then false else true
    $.cookie('gallery_visible', Gallery.visible)
    transition_off = -> $('body').addClass('transition-off')
    setTimeout(transition_off, 600)

  Sidebar = {}
  Sidebar.current_tab = 'scopes'

  ScopeHunter = {}
  ScopeHunter.visible = angular.fromJson($.cookie("scopehunter_visible") || false)
  ScopeHunter.toggle = ->
    ScopeHunter.visible = if ScopeHunter.visible then false else true
    $.cookie('scopehunter_visible', ScopeHunter.visible)

  version = $("#version").attr("content")
  current_theme = {}

  {
    Gallery
    Sidebar
    ScopeHunter
    version
    current_theme
  }
]
