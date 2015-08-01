Template = require('mincer/lib/mincer/template')
prop     = require('mincer/lib/mincer/common').prop
templatecache = require('ng-templatecache')

ngTemplatesEngine = module.exports = ->
  Template.apply this, arguments
  return

require('util').inherits(ngTemplatesEngine, Template)

ngTemplatesEngine::evaluate = (context) ->
  @data = templatecache(
    entries: [{
      content: @data
      path: context.logicalPath + context.environment.attributesFor(context.pathname).extensions.join('')
    }]
    module: 'templates'
    standalone: false
  )
  return

prop ngTemplatesEngine, 'defaultMimeType', 'application/javascript'
