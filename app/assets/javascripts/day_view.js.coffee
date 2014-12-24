app = angular.module("dayView", [])
app.controller "dayViewController", ($scope) ->

  $scope.calendarStartDate = new Date()

  $scope.employees = [
    {id: '1', name: 'Fordon Ng'},
    {id: '2', name: 'Zadwin Feng'}
    {id: '3', name: 'Kan G'}
  ]

  $scope.shifts = [
    {id: '1', employeeID: "1", length: 5.5, startHour: 10, startMin: 30, role: 'Manager', endHour: 16, endMin: '00'},
    {id: '2', employeeID: "2", length: 8, startHour: 12, startMin: 15, role: 'Assistant Manager', endHour: 20, endMin: 15}
  ]

  $scope.leaves = [
    {employeeID: '3', date: '24-12-2014', length: 2, morningStart: true}
  ]

  $scope.employeesAndOffset = {}
  $scope.hoursAndOffset = {}

  $scope.shiftColors = {'Manager': 'orangered', 'Assistant Manager': 'green'}

  grabShift = (shiftID) ->
    for shift in $scope.shifts
      return shift if parseInt(shift.id) is shiftID


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



  $ ->

    $('.shift-applicable').droppable({
      accept: '.shift-bar',
      activeClass: "ui-state-highlight"
    })

    tdWidth             = parseInt($('.shift-applicable').first().css('width'))
    fifteenMinWidth     =  tdWidth/4
    tdHeight            = parseInt($('.shift-applicable').first().css('height'))

    $scope.setShifts = ->
      $('.shift-bar').each (i,v) ->
        shiftHours  =  $(v).data('length')
        shiftWidth  =  ((shiftHours + 1) * tdWidth - 5)
        shiftHeight =  tdHeight - 10

        role       = $(this).data('role')
        shiftColor = $scope.shiftColors[role]


        $(v).css('width', shiftWidth).css('height', shiftHeight).css('background-color', shiftColor)

        employeeID   = $(this).data('employee-id')
        employeeRow  =  $('tr[data-employee-id="' + employeeID + '"]')
        
        startingHour    = $(this).data('start-hour')
        startingMin    = $(this).data('start-min')
        shiftStartingTD = $(employeeRow).find('td[data-hour=' +  startingHour + ']')

        offset          = $(shiftStartingTD).offset()

        offset.top  += 5
        offset.left += (5 + (startingMin/15 * fifteenMinWidth) )

        $(this).offset(offset)

        $(this).css('z-index', 20 - shiftHours)

        endingHour = $(this).data('end-hour')

    $scope.setShifts()
      
    $('.shift-bar').draggable({
      opacity: 0.3,
      grid: [ tdWidth/4, tdHeight],
      revert: 'invalid',
      cursor: 'move',
      zIndex: 100,
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
        newEndMin   = newStartMin + 60*(shiftLength - Math.floor(shiftLength))

        #adjust for min going past 60
        if newEndMin >= 60
          newEndMin  = newEndMin - 60 
          newEndHour++

        #set new variables
        draggedShift.employeeID = newEmployeeID
        draggedShift.startHour  = newStartHour
        draggedShift.startMin   = if newStartMin is 0 then "00" else newStartMin        
        draggedShift.endHour    = newEndHour
        draggedShift.endMin     = if newEndMin is 0 then "00" else newEndMin

        $scope.$apply()
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