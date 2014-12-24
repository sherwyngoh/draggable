app = angular.module("dayView", [])
app.controller "dayViewController", ($scope) ->

  $scope.calendarStartDate   = '24-12-2014'
  $scope.calendarDisplayDate = moment($scope.calendarStartDate, "DD-MM-YYYY").format('LL')

  $scope.employees = [
    {id: '1', name: 'Fordon Ng', hoursExcludingThisWeek: 20, costPerHour: 10, totalHours: 40, currentWeekHours: 5.5},
    {id: '2', name: 'Zadwin Feng', hoursExcludingThisWeek: 16, costPerHour: 7.5, totalHours: 40, currentWeekHours: 8}
    {id: '3', name: 'Kan G', hoursExcludingThisWeek: 10, costPerHour: 7, totalHours: 35, currentWeekHours: 0}
    {id: '4', name: 'Lesslyn Yoon', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0}
  ]

  $scope.shifts = [
    {id: '1', employeeID: "1", length: 5.5, startHour: 10, startMin: 30, role: 'Manager', endHour: 16, endMin: '00'},
    {id: '2', employeeID: "2", length: 8, startHour: 12, startMin: 15, role: 'Assistant Manager', endHour: 20, endMin: 15}
  ]

  $scope.leaves = [
    {employeeID: '3', fullDay: false, startHour: 12}
    {employeeID: '4', fullDay: true, startHour: 12}
  ]
  
  $scope.employeesAndOffset = {}
  $scope.hoursAndOffset     = {}
  
  $scope.shiftColors   = {'Manager': '#3498DB', 'Assistant Manager': '#2ECC71'}
  $scope.selectedShift = {}
  $scope.roles         = ["Manager", "Assistant Manager", "Supervisor", "Crew"]
  $scope.showPopup     = false

  grabShift = (shiftID) ->
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


  grabEmployee = (employeeID) ->
    for employee in $scope.employees
      return employee if parseInt(employee.id) is parseInt(employeeID)

  setCalendarHours = ->
    #set the calendar start and end times
    min = 24
    max = 0
    for shiftID, shift of $scope.shifts
      min     =  shift.startHour if min > shift.startHour
      max     =  shift.endHour if max < shift.endHour
    max += 2

    while min < max
      $scope.hoursAndOffset[min] = ""
      min++

  setCalendarHours()


  $ ->
    #popup handler
    $('.fa-minus').on 'click', ->
      $('.popup ng-form').hide()
      $(this).hide()
      $('.fa-plus').show()

    $('.fa-plus').on 'click', ->
      $('.popup ng-form').show()
      $(this).hide()
      $('.fa-minus').show()

    $('.popup').draggable({
      cursor: 'grabbing !important',
      opacity: 0.6,
    })

    $(window).on 'resize', ->
      location.reload()


    tdWidth             = parseInt($('.shift-applicable').first().css('width'))
    fifteenMinWidth     =  tdWidth/4
    tdHeight            = parseInt($('.shift-applicable').first().css('height'))

    #set leave bars
    for leave in $scope.leaves
      employeeID   = leave.employeeID
      employeeRow  = $('tr[data-employee-id="' + employeeID + '"]')
      employeeTD   = $(employeeRow).find('td.employee-name > span')
      if leave.fullDay
        leaveTDs = $(employeeRow).find('td:not(.employee-name)')
        $(employeeTD).append('<small> (on full-day leave) </small>')

      else
        $(employeeTD).append('<small> (on half-day leave) </small>')
        leaveTDs = $(employeeRow).find('td:not(.employee-name)').filter ()->
          return parseInt($(this).data('hour')) >= leave.startHour

      $(leaveTDs).each () ->
        $(this).css('background', 'whitesmoke')

    $scope.setShifts = ->
      $('.shift-bar').each () ->
        shiftHours  =  $(this).data('length')
        shiftWidth  =  (shiftHours * tdWidth)
        shiftHeight =  tdHeight - 10

        role       = $(this).data('role')
        shiftColor = $scope.shiftColors[role]

        $(this).css('width', shiftWidth).css('height', shiftHeight).css('background-color', shiftColor)

        employeeID   = $(this).data('employee-id')
        employeeRow  =  $('tr[data-employee-id="' + employeeID + '"]')
        
        startingHour    = $(this).data('start-hour')
        startingMin     = $(this).data('start-min')
        shiftStartingTD = $(employeeRow).find('td[data-hour=' +  startingHour + ']')

        offset           = $(shiftStartingTD).offset()
        offset.top      += 5
        offset.left     += (5 + (startingMin/15 * fifteenMinWidth) )

        $(this).offset(offset)

        $(this).css('z-index', 20 - shiftHours)

        endingHour = $(this).data('end-hour')

    $scope.setShifts()

    $('.shift-bar').draggable({
      opacity: 0.4,
      grid: [ tdWidth/4, tdHeight],
      revert: 'invalid',
      cursor: 'grabbing !important',
      stop: (event, ui) ->
        top             = $(this).offset().top
        left            = $(this).offset().left
        shiftID         = $(this).data('shift-id')
        shiftLength     = $(this).data('length')
        currentStartMin = $(this).data('data-start-min')

        for hour, offset of $scope.hoursAndOffset
          newStartHour  = hour if offset < left

        for employee, offset of $scope.employeesAndOffset
          newEmployeeID = employee if offset < top

        #get the shift object
        draggedShift = grabShift(shiftID)

        #find new hour
        offset       = $scope.hoursAndOffset[parseInt(newStartHour) + 1]

        #determine new start and end times
        newStartMin = (4 - (Math.ceil((offset - left)/fifteenMinWidth)))*15
        newEndHour  = parseInt(newStartHour) + Math.floor(shiftLength)
        minDuration = shiftLength - Math.floor(shiftLength)
        newEndMin   = newStartMin + 60*minDuration
        console.log newEndHour, newEndMin
        #adjust for min going past 60
        if newEndMin >= 60
          newEndMin  = newEndMin - 60
          newEndHour += 1
        console.log newEndHour, newEndMin

        #adjust working hours if employee changed
        if draggedShift.employeeID isnt newEmployeeID
          shiftTakenFrom                  = grabEmployee(draggedShift.employeeID)
          shiftGivenTo                    = grabEmployee(newEmployeeID)
          shiftTakenFrom.currentWeekHours = shiftTakenFrom.currentWeekHours - draggedShift.length
          shiftGivenTo.currentWeekHours   = shiftGivenTo.currentWeekHours + draggedShift.length

        #set new variables
        draggedShift.employeeID = newEmployeeID
        draggedShift.startHour  = newStartHour
        draggedShift.startMin   = if newStartMin is 0 then "00" else newStartMin        
        draggedShift.endHour    = newEndHour
        draggedShift.endMin     = if newEndMin is 0 then "00" else newEndMin

        $scope.$apply()
    })

    $('.shift-applicable').droppable({
      accept: '.shift-bar',
      activeClass: "ui-state-highlight"
    })
    # Find left offset for each hour
    $('.shift-applicable').each () ->
      hour                        = $(this).data('hour')
      left                        = $(this).offset().left
      $scope.hoursAndOffset[hour] = left

    # Find top offset for each employee
    $("tbody tr").each () ->
      id                            = $(this).data("employee-id")
      top                           = $(this).offset().top
      $scope.employeesAndOffset[id] = top