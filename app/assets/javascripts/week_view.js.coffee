window.app = app = angular.module "weekView", []

app.controller "weekViewController", ($scope, $timeout) ->

  $scope.states =
    showEditPopup  : false
    showNewPopup   : false
    isSelecting    : false
    isCloning      : false
    isInitializing : true

  $scope.func =
    grabShift: (shiftID) ->
      for shift in $scope.data.shifts
        return shift if parseInt(shift.id) is parseInt(shiftID)

    setShift: (shiftID) ->
      $scope.selectedShift    = $scope.func.grabShift(shiftID)
      $scope.states.showPopup = true

    updateShift: (updatedShift) ->
      $scope.states.showEditPopup = false
      $timeout($scope.func.refreshCalendar, 0)
      shiftToUpdate = $scope.func.grabShift(updatedShift.id)
      shifts        = $scope.data.shifts
      index         = shifts.indexOf(shiftToUpdate)
      shifts.splice(index, 1, updatedShift)
      $scope.func.updateShiftColor(updatedShift)
      $scope.data.selectedShift = {}

    resetSelected: ->
      $scope.data.toggledShifts = []
      $scope.states.isSelecting   = false

    submitShift: (shift) ->
      hours        = shift.endHour - shift.startHour
      hours        += (shift.endMin - shift.startMin)/60
      shift.length = hours
      shift.id     = $scope.data.shifts.length + 1
      $scope.data.shifts.push(shift)
      $scope.data.newShift       = {role: $scope.data.roles[0], breakHours: 1, startHour: 8, startMin: '00', endHour: 17, endMin: '00'}
      $scope.states.showNewPopup = false
      $scope.data.baseShift      = {}
      $scope.$apply()
      $timeout($scope.func.refreshCalendar, 0)

    removeShifts: (shiftsArray) ->
      for shiftID in shiftsArray
        shift = $scope.func.grabShift(shiftID)
        index = $scope.data.shifts.indexOf(shift)
        if index > -1
          $scope.data.shifts.splice(index, 1)
      $timeout($scope.func.refreshCalendar, 0)

  #init
  $scope.data =
    daysInWeek    : []
    toggledShifts : []
    selectedShift : {}
    baseShift     : {}

  $scope.data.calendarStartDate    = '27-12-2014'
  $scope.data.calMomentStart       = moment($scope.data.calendarStartDate, "DD-MM-YYYY")
  $scope.data.calMomentEnd         = moment($scope.data.calendarStartDate, "DD-MM-YYYY").add(6, 'days')
  $scope.data.calendarDisplayDate  = $scope.data.calMomentStart.format('ddd Do MMM YYYY') + " - " + $scope.data.calMomentEnd.format('ddd Do MMM YYYY')

  $scope.data.employees = [
    {id: '1', name: 'Fordon Ng', hoursExcludingThisWeek: 20, costPerHour: 10, totalHours: 40, currentWeekHours: 5.5}
    {id: '2', name: 'Zadwin Feng', hoursExcludingThisWeek: 16, costPerHour: 7.5, totalHours: 40, currentWeekHours: 8}
    {id: '3', name: 'Kan G', hoursExcludingThisWeek: 10, costPerHour: 7, totalHours: 35, currentWeekHours: 0}
    {id: '4', name: 'Lesslyn Yoon', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0}
  ]

  $scope.data.shifts = [
    {id: '1', employeeID: "1", length: 5.5, startHour: 10, startMin: 30, role: 'Manager', endHour: 16, endMin: '00', date: '27-12-2014', breakHours: 1},
    {id: '2', employeeID: "2", length: 8, startHour: 12, startMin: 15, role: 'Asst Manager', endHour: 20, endMin: 15, date: '28-12-2014', breakHours: 1.5}
    {id: '3', employeeID: "3", length: 8, startHour: 10, startMin: '00', role: 'Supervisor', endHour: 18, endMin: '00', date: '30-12-2014', breakHours: 2}
    {id: '4', employeeID: "3", length: 8, startHour: 12, startMin: 15, role: 'Crew', endHour: 20, endMin: 15, date: '29-12-2014', breakHours: 1.5}
  ]

  $scope.data.leaves = [
    {employeeID: '3', fullDay: false, startHour: 12}
    {employeeID: '4', fullDay: true, startHour: 12}
  ]

  $scope.data.shiftColors   = {'Manager': '#3498DB', 'Asst Manager': '#2ECC71', 'Supervisor': '#9B59B6', 'Crew': '#F39C12'}
  $scope.data.roles         = ["Manager", "Asst Manager", "Supervisor", "Crew"]
  $scope.data.newShift      = {role: $scope.data.roles[0], breakHours: 1, startHour: 8, startMin: '00', endHour: 17, endMin: '00'}

app.filter 'acronymify', () ->
  return (input) ->
    return input.match(/\b(\w)/g).join('')