Application.factory "Editor", [ ->

  Gallery = {}
  Gallery.visible = angular.fromJson($.cookie("gallery_visible") || false)
  Gallery.toggle = ->
    if Gallery.visible
      Gallery.visible = false
      $.cookie('gallery_visible', false)
    else
      Gallery.visible = true
      $.cookie('gallery_visible', true)

  version = $("#version").attr("content")

  current_theme = {}

  {
    Gallery
    version
    current_theme
  }
]
