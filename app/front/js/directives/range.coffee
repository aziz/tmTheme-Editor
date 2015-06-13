Application.directive 'input', ->
  restrict: 'E'
  require: '?ngModel'
  link: (scope, element, attrs, ngModel) ->
    if 'type' of attrs and attrs.type.toLowerCase() == 'range'
      ngModel.$parsers.push parseFloat
    return
