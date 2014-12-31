app = angular.module "weekView", ['weekViewDirectives']

app.controller "weekViewController", ($scope, $timeout) ->

  $scope.calendarStartDate    = '27-12-2014'
  $scope.calMomentStart       = moment($scope.calendarStartDate, "DD-MM-YYYY")
  $scope.calMomentEnd         = moment($scope.calendarStartDate, "DD-MM-YYYY").add(6, 'days')
  $scope.calendarDisplayDate  = $scope.calMomentStart.format('ddd Do MMM YYYY') + " - " + $scope.calMomentEnd.format('ddd Do MMM YYYY')

  $scope.employees = [
    {id: '1', name: 'Fordon Ng', hoursExcludingThisWeek: 20, costPerHour: 10, totalHours: 40, currentWeekHours: 5.5},
    {id: '2', name: 'Zadwin Feng', hoursExcludingThisWeek: 16, costPerHour: 7.5, totalHours: 40, currentWeekHours: 8}
    {id: '3', name: 'Kan G', hoursExcludingThisWeek: 10, costPerHour: 7, totalHours: 35, currentWeekHours: 0}
    {id: '4', name: 'Lesslyn Yoon', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0}
  ]

  $scope.daysInWeek         = []
  $scope.test = {id: '1', employeeID: "1", length: 5.5, startHour: 10, startMin: 30, role: 'Manager', endHour: 16, endMin: '00', date: '27-12-2014', breakHours: 1}

  $scope.shifts = [
    {id: '1', employeeID: "1", length: 5.5, startHour: 10, startMin: 30, role: 'Manager', endHour: 16, endMin: '00', date: '27-12-2014', breakHours: 1},
    {id: '2', employeeID: "2", length: 8, startHour: 12, startMin: 15, role: 'Asst Manager', endHour: 20, endMin: 15, date: '28-12-2014', breakHours: 1.5},
    {id: '3', employeeID: "3", length: 8, startHour: 10, startMin: '00', role: 'Supervisor', endHour: 18, endMin: '00', date: '30-12-2014', breakHours: 2},
    {id: '4', employeeID: "3", length: 8, startHour: 12, startMin: 15, role: 'Crew', endHour: 20, endMin: 15, date: '29-12-2014', breakHours: 1.5},
  ]

  $scope.leaves = [
    {employeeID: '3', fullDay: false, startHour: 12}
    {employeeID: '4', fullDay: true, startHour: 12}
  ]

  $scope.shiftColors   = {'Manager': '#3498DB', 'Asst Manager': '#2ECC71', 'Supervisor': '#9B59B6', 'Crew': '#F39C12'}
  $scope.roles         = ["Manager", "Asst Manager", "Supervisor", "Crew"]

  $scope.selectedShift = {}
  $scope.baseShift     = {}

  $scope.newShift      = {role: $scope.roles[0], breakHours: 1, startHour: 8, startMin: '00', endHour: 17, endMin: '00'}

  $scope.toggledShifts = []

  $scope.commonShifts  = [
    {id: '1', title: 'Opening', length: 8, startHour: 7, startMin: 30, endHour: 15, endMin: 30, breakHours: 1, role: "Crew"},
    {id: '2', title: 'Closing', length: 8, startHour: 15, startMin: '00', endHour: 23, endMin: 30, breakHours: 1, role: "Crew"},
    {id: '3', title: 'Opening', length: 8, startHour: 7, startMin: 30, endHour: 15, endMin: 30, breakHours: 1, role: "Supervisor"},
    {id: '4', title: 'Closing', length: 8, startHour: 15, startMin: '00', endHour: 23, endMin: 30, breakHours: 1, role: "Supervisor"},
    {id: '5', title: 'Opening', length: 8, startHour: 7, startMin: 30, endHour: 15, endMin: 30, breakHours: 1, role: "Asst Manager"},
    {id: '6', title: 'Closing', length: 8, startHour: 15, startMin: '00', endHour: 23, endMin: 30, breakHours: 1, role: "Asst Manager"},
    {id: '7', title: 'Opening', length: 8, startHour: 7, startMin: 30, endHour: 15, endMin: 30, breakHours: 1, role: "Manager"},
    {id: '8', title: 'Closing', length: 8, startHour: 15, startMin: '00', endHour: 23, endMin: 30, breakHours: 1, role: "Manager"},
  ]

  $scope.grabShift = (shiftID) ->
    for shift in $scope.shifts
      return shift if parseInt(shift.id) is parseInt(shiftID)

  $scope.setShift = (shiftID) ->
    $scope.selectedShift = grabShift(shiftID)
    $scope.showPopup     = true

  $scope.updateShift = (updatedShift) ->
    # oldShift             = grabShift(updatedShift.id)
    # index                = $scope.shifts.indexOf(oldShift)
    # $scope.shifts[index] = updatedShift
    # $scope.$apply()
    $scope.showPopup     = false

  $scope.resetSelected = ->
    $scope.toggledShifts = []
    $scope.isSelecting   = false

  $scope.submitShift = (shift) ->
    hours        = shift.endHour - shift.startHour
    hours        += (shift.endMin - shift.startMin)/60
    shift.length = hours
    shift.id     = $scope.shifts.length + 1
    $scope.shifts.push(shift)
    $scope.newShift      = {role: $scope.roles[0], breakHours: 1, startHour: 8, startMin: '00', endHour: 17, endMin: '00'}
    $scope.showNewPopup  = false
    $scope.baseShift     = {}
    $scope.$apply()
    $timeout($scope.refreshCalendar, 0)

  $scope.removeShifts = (shiftsArray) ->
    for shiftID in shiftsArray
      shift = $scope.grabShift(shiftID)
      index = $scope.shifts.indexOf(shift)
      if index > -1
        $scope.shifts.splice(index, 1)
    $timeout($scope.refreshCalendar, 0)

app.filter 'acronymify', () ->
  return (input) ->
    return input.match(/\b(\w)/g).join('')