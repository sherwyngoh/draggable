window.app = app = angular.module "weekView", []

app.controller "weekViewController", ($scope, $timeout) ->
  #SS new shift breaks estimates, test cloning
  $scope.states =
    showEditPopup    : false
    showNewPopup     : false
    isSelecting      : false
    isCloning        : false
    isInitializing   : true
    showMenu         : false
    showHelp         : false
    showTemplateMenu : false
    showSortMenu     : false

  #init
  $scope.data =
    daysInWeek    : []
    toggledShifts : []
    selectedShift : {}
    shiftCopy     : {}
    baseShift     : {}
    attrToClone   : ['startHour','startMin','role','endHour','endMin','breakHours', 'employeeID', 'date']
    wageEstimate  : 0
    predicate     : 'id'
    reverse       : false

  $scope.data.calendarStartDate    = '27-12-2014'
  $scope.data.calMomentStart       = moment($scope.data.calendarStartDate, "DD-MM-YYYY")
  $scope.data.calMomentEnd         = moment($scope.data.calendarStartDate, "DD-MM-YYYY").add(6, 'days')
  $scope.data.calendarDisplayDate  = $scope.data.calMomentStart.format('ddd Do MMM YYYY') + " - " + $scope.data.calMomentEnd.format('ddd Do MMM YYYY')

  $scope.data.employees = [
    {id: '1', name: 'Fordon Ng', hoursExcludingThisWeek: 20, costPerHour: 10, totalHours: 40, currentWeekHours: 5.5, defaultRole: 'Manager'}
    {id: '2', name: 'Zadwin Feng', hoursExcludingThisWeek: 16, costPerHour: 7.5, totalHours: 40, currentWeekHours: 8, defaultRole: 'Crew'}
    {id: '3', name: 'Kan G', hoursExcludingThisWeek: 10, costPerHour: 7, totalHours: 35, currentWeekHours: 0, defaultRole: 'Asst Manager' }
    {id: '4', name: 'Lesslyn', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Asst Manager'}
    {id: '5', name: 'Zherwyn', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Supervisor'}
    {id: '6', name: 'Jebastian', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Supervisor'}
    {id: '7', name: 'Bnonoz', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Crew' }
    {id: '8', name: 'Zordon', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Supervisor'}
    {id: '9', name: 'White Ranger', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Supervisor'}
    {id: '10', name: 'Red Ranger', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Manager'}
    {id: '11', name: 'Black Ranger', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Crew'}
    {id: '12', name: 'Yellow Ranger', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Crew'}
  ]

  $scope.data.shifts = [
    {id: '1', employeeID: "1", length: 5.5, startHour: 10, startMin: 30, role: 'Manager', endHour: 16, endMin: '00', date: '27-12-2014', breakHours: 1},
    {id: '2', employeeID: "2", length: 8, startHour: 12, startMin: 15, role: 'Asst Manager', endHour: 20, endMin: 15, date: '28-12-2014', breakHours: 1.5}
    {id: '3', employeeID: "3", length: 8, startHour: 10, startMin: '00', role: 'Supervisor', endHour: 18, endMin: '00', date: '30-12-2014', breakHours: 2}
    {id: '4', employeeID: "3", length: 8, startHour: 12, startMin: 15, role: 'Crew', endHour: 20, endMin: 15, date: '29-12-2014', breakHours: 1.5}
  ]

  $scope.data.originalShifts = [
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

  $scope.data.salesForecast    = "2000"
  $scope.data.budgetPercentage = "15"
  $scope.data.wageBudget       =  ($scope.data.salesForecast/100) *  $scope.data.budgetPercentage

  $scope.$watchGroup ['data.salesForecast', 'data.budgetPercentage'], (newVal, oldVal, scope) ->
    scope.data.wageBudget       =  ($scope.data.salesForecast/100) *  $scope.data.budgetPercentage

  $scope.$watchGroup ['states.showNewPopup', 'states.showEditPopup'], (newVal, oldVal, scope) ->
    for val in newVal
      if val is true
        scope.states.showMenu = false
        scope.states.showTemplateMenu = false
        scope.func.resetSelected()

  $scope.func =
    goToSummary: ->
      $('summary .fa-plus').click()
      $.scrollTo($('summary').offset().top - 120, 300)

    estimate: ->
      console.log 'estimating wagecost and setting employee current working hours'
      $scope.data.wageEstimate = 0

      for employee in $scope.data.employees
        employee.currentWeekHours = 0

      for day in $scope.data.daysInWeek
        day[2] = day[3] = 0
        shiftBars = $('.shift-bar[data-date="' + day[1] + '"')
        angular.forEach shiftBars, (shiftBar) ->
          shift                     = $scope.func.grabShift($(shiftBar).data('shift-id'))
          employee                  = $scope.func.grabEmployee(shift.employeeID)
          wageCost                  = parseInt(employee.costPerHour) * parseInt(shift.length)
          day[2]                    += wageCost
          day[3]                    += shift.length

          $scope.data.wageEstimate  += wageCost

          employee.currentWeekHours += parseInt(shift.length)





    swal: (ifSuccess, confirmButtonText, confirmButtonColor, type) ->
      confirmButtonColor = "#DD6B55" unless confirmButtonColor
      type = 'warning' unless type
      swal
        title: "Are you sure?"
        # text: "You will not be able to recover this imaginary file!"
        type: type
         # "warning", "error", "success" and "info"
        showCancelButton: true
        confirmButtonColor: confirmButtonColor
        confirmButtonText: confirmButtonText
        closeOnConfirm: true
        , ->
          ifSuccess()
          $scope.func.estimate()

    deleteAll: ->
      ifSuccess = ->
        $scope.data.shifts = []
        $scope.$apply()
      $scope.func.swal(ifSuccess, "Yes, delete all shifts!")

    resetShifts: ->
      ifSuccess = ->
        angular.copy($scope.data.originalShifts, $scope.data.shifts)
        $timeout($scope.func.refreshCalendar, 0)
        $scope.$apply()
      $scope.func.swal(ifSuccess, "Yes, reset all changes!", '#F1C40F')

    toggled: ->
      shifts  = $scope.data.shifts
      toggled = $scope.data.toggledShifts
      for shift in shifts
        shiftBar   = $('.shift-bar[data-shift-id="' + shift.id + '"]')
        role       = shift.role
        shiftColor = $scope.data.shiftColors[role]
        if toggled.indexOf(parseInt(shift.id)) is -1
          shiftBar
            .css('color', shiftColor)
            .css('background-color', 'white')
            .css('border', '3px solid ' + shiftColor)
        else
          shiftBar
            .css('color', 'white')
            .css('background-color', shiftColor)
            .css('border', '3px solid ' + shiftColor)

    resetForm: (form) ->
      $scope.data.shiftCopy =  angular.copy($scope.data.selectedShift)
      $scope.$apply()

    grabEmployee: (employeeID) ->
      for employee in $scope.data.employees
        return employee if parseInt(employee.id) is parseInt(employeeID)

    grabShift: (shiftID) ->
      for shift in $scope.data.shifts
        return shift if parseInt(shift.id) is parseInt(shiftID)

    setShift: (shiftID) ->
      $scope.selectedShift    = $scope.func.grabShift(shiftID)
      $scope.states.showPopup = true

    updateShift: (shiftCopy) ->
      shiftToUpdate = $scope.data.selectedShift

      attrToClone    = $scope.data.attrToClone
      for attr in attrToClone
        shiftToUpdate[attr] = shiftCopy[attr]

      $scope.func.updateShiftColor(shiftToUpdate)
      $scope.data.selectedShift = {}
      $scope.states.showEditPopup = false
      $timeout($scope.func.refreshCalendar, 0)
      $scope.func.toggled()

    resetSelected: ->
      $scope.data.selectedShift = {}
      $scope.data.toggledShifts = []
      $scope.states.isSelecting   = false
      $scope.func.toggled()

    createFromPopup: ->
      shiftToPush = {}
      angular.copy($scope.data.newShift, shiftToPush)

      shiftToPush = $scope.func.setIdAndLength(shiftToPush)
      $scope.data.shifts.push(shiftToPush)

      #reset new shift and close popup
      $scope.data.newShift       = {role: $scope.data.roles[0], breakHours: 1, startHour: 8, startMin: '00', endHour: 17, endMin: '00'}
      $scope.states.showNewPopup = false
      $timeout($scope.func.refreshCalendar, 0)

    submitShift: (shift) ->
      shift = $scope.func.setIdAndLength(shift)
      $scope.data.shifts.push(shift)
      $scope.data.baseShift = {}
      $scope.$apply()
      $timeout($scope.func.refreshCalendar, 0)

    setIdAndLength: (shift) ->
      hours        = shift.endHour - shift.startHour
      hours        += (shift.endMin - shift.startMin)/60
      shift.length = hours
      shift.id     = String($scope.data.shifts.length + 1)
      return shift

    removeShifts: (shiftsArray) ->
      for shiftID in shiftsArray
        shift = $scope.func.grabShift(shiftID)
        index = $scope.data.shifts.indexOf(shift)
        if index > -1
          $scope.data.shifts.splice(index, 1)

      $timeout($scope.func.refreshCalendar, 0)
      $scope.func.resetSelected()

    refreshCalendar: ->
      console.log 'refreshing calendar'
      for shift in $scope.data.shifts
        employeeID      = shift.employeeID
        employeeRow     = $('tr[data-employee-id="' + employeeID + '"]')
        shiftStartingUL = $(employeeRow).find('td[data-date=' +  shift.date + ']')
        element         = $('.shift-bar[data-shift-id="' + shift.id + '"]')
        shiftStartingUL.append(element)

      REDIPS.drag.init('week-view')
      $scope.states.isInitializing = false
      $scope.func.estimate()


app.filter 'acronymify', () ->
  return (input) ->
    return input.match(/\b(\w)/g).join('')