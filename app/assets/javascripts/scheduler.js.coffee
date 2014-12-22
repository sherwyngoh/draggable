app = angular.module("schedulerApp", [])

app.controller "SchedulerController", ($scope) ->
  $scope.currentDay = ["Sunday"]
  $scope.pushDay = (day) ->
    if $scope.currentDay.indexOf(day) is -1
      $scope.currentDay.push(day)
    else
      $scope.currentDay.splice($scope.currentDay.indexOf(day),1)

  $('.filled-by').tagit()
