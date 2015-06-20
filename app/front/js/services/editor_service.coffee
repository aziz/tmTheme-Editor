Application.factory "Editor", [ ->

  Gallery = {}
  Gallery.visible = angular.fromJson($.cookie("gallery_visible") || false)
  Gallery.filter = {name: ''}
  Gallery.toggle = ->
    $('body').removeClass('transition-off')
    if Gallery.visible
      Gallery.visible = false
      $.cookie('gallery_visible', Gallery.visible)
    else
      Gallery.visible = true
      $.cookie('gallery_visible', Gallery.visible)
    transition_off = -> $('body').addClass('transition-off')
    setTimeout(transition_off, 600)

  version = $("#version").attr("content")

  Sidebar = {}
  Sidebar.current_tab = 'scopes'

  current_theme = {}

  {
    Gallery
    Sidebar
    version
    current_theme
  }
]
