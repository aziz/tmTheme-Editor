Application.controller 'ModalOpenURLController', ['$scope','$modalInstance', 'themeExternalURL', ($scope, $modalInstance, themeExternalURL) ->
  $scope.themeExternalURL = themeExternalURL
  $scope.ok = -> $modalInstance.close $scope.themeExternalURL
  $scope.cancel = -> $modalInstance.dismiss 'cancel'
]
