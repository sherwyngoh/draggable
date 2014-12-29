app = angular.module "weekView", []

app.controller "weekViewController", ($scope, $timeout) ->
  redipsInit = ->
    num = 0 # number of successfully placed elements
    rd = REDIPS.drag # reference to the REDIPS.drag lib
    rd.init('week-view')
    # rd.tableSort = true -> default

    # set hover color
    rd.hover.colorTd = '#9BB3DA'
    rd.hover.borderTd = '2px solid #9bb3da'

    # rd.mark.exception.green   = "green_cell"
    # rd.mark.exception.greenc0 = "green_cell"
    # rd.mark.exception.greenc1 = "green_cell"
    
    # rd.mark.exception.orange   = "orange_cell"
    # rd.mark.exception.orangec0 = "orange_cell"
    # rd.mark.exception.orangec1 = "orange_cell"

    rd.trash.question = 'Are you sure you want to delete this shift?'

    rd.event.clicked = (currentCell)->
      if window.event.metaKey
        shiftID            = $(rd.obj).data('shift-id')
        toggleItemInArray($scope.toggledShifts, shiftID)
        $scope.isSelecting = if $scope.toggledShifts.length > 0 then true else false
        $scope.$apply()
      else if currentCell.classList.contains('common-shifts')
        $scope.showPopup     = false
        $scope.$apply()
      else
        $scope.isDragging = true
        $scope.$apply() 

    rd.event.notCloned = ->
      $scope.isDragging = false
      $scope.$apply()

    rd.event.notMoved = ->
      if !(window.event.ctrlKey or window.event.metaKey)
        $scope.isDragging    = false
        shiftID              = $(rd.obj).data('shift-id')
        $scope.selectedShift = grabShift(shiftID)
        $scope.showPopup     = true
        $scope.$apply()

    rd.event.deleted = ->
      $scope.isDragging = false
      $scope.$apply()

    rd.event.dropped = ->
      $scope.isDragging = false
      $scope.$apply()
      console.log $(rd.td.source)
      console.log $(rd.td.target)
      console.log $(rd.td.previous)
      console.log $(rd.obj)
      # if rd.td.target.className.indexOf(rd.mark.exception[rd.obj.id]) isnt -1
        
      #   # make it a unmovable
      #   rd.enableDrag false, rd.obj
        
      #   # increase counter
      #   num++
        
      #   # prepare and display message
      #   if num < 6
      #     msg = "Number of successfully placed elements: " + num
      #   else
      #     msg = "Well done!"
      #   document.getElementById("message").innerHTML = msg
      # return
    return

  # add onload event listener
  if window.addEventListener
    window.addEventListener "load", redipsInit, false
  else window.attachEvent "onload", redipsInit  if window.attachEvent

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
  
  $scope.employeesAndOffset = {}
  $scope.daysInWeek         = []

  $scope.shiftColors   = {'Manager': '#3498DB', 'Asst Manager': '#2ECC71', 'Supervisor': '#9B59B6', 'Crew': '#F39C12'}
  $scope.roles         = ["Manager", "Asst Manager", "Supervisor", "Crew"]

  $scope.selectedShift = {}
  $scope.showPopup     = false

  $scope.newShift      = {role: $scope.roles[0], breakHours: 1, startHour: 8, startMin: '00', endHour: 17, endMin: '00'}
  $scope.showNewPopup  = false

  $scope.isDragging    = false
  $scope.isSelecting   = false

  $scope.toggledShifts = []

  $scope.commonShifts  = [
    {title: 'Opening', length: 8, startHour: 7, startMin: 30, endHour: 15, endMin: 30, breakHours: 1, role: "Crew"},
    {title: 'Closing', length: 8, startHour: 15, startMin: '00', endHour: 23, endMin: 30, breakHours: 1, role: "Crew"},
    {title: 'Opening', length: 8, startHour: 7, startMin: 30, endHour: 15, endMin: 30, breakHours: 1, role: "Supervisor"},
    {title: 'Closing', length: 8, startHour: 15, startMin: '00', endHour: 23, endMin: 30, breakHours: 1, role: "Supervisor"},
    {title: 'Opening', length: 8, startHour: 7, startMin: 30, endHour: 15, endMin: 30, breakHours: 1, role: "Asst Manager"},
    {title: 'Closing', length: 8, startHour: 15, startMin: '00', endHour: 23, endMin: 30, breakHours: 1, role: "Asst Manager"},
    {title: 'Opening', length: 8, startHour: 7, startMin: 30, endHour: 15, endMin: 30, breakHours: 1, role: "Manager"},
    {title: 'Closing', length: 8, startHour: 15, startMin: '00', endHour: 23, endMin: 30, breakHours: 1, role: "Manager"},
  ]

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

  $scope.resetSelected = ->
    $scope.toggledShifts = []
    $scope.isSelecting   = false

  $scope.submitShift = (newShift) ->
    $scope.shifts.push(newShift)
    $scope.showNewPopup = false

  $scope.removeShifts = (shiftsArray) ->
    for shiftID in shiftsArray
      shift = grabShift(shiftID)
      index = $scope.shifts.indexOf(shift)
      if index > -1
        $scope.shifts.splice(index, 1)
    $timeout($scope.refreshCalendar, 0)

  $scope.refreshCalendar = ()->
    for shift in $scope.shifts
      employeeID   = shift.employeeID
      employeeRow  =  $('tr[data-employee-id="' + employeeID + '"]')
      
      date            = shift.date
      shiftStartingUL = $(employeeRow).find('td[data-date=' +  date + '] .sortable')
      element         = $('.shift-bar[data-shift-id="'+shift.id+'"]')
      shiftStartingUL.append(element)
    return

  grabEmployee = (employeeID) ->
    for employee in $scope.employees
      return employee if parseInt(employee.id) is parseInt(employeeID)

  setCalendarDays = ->
    #set the calendar start and end times
    min = $scope.calMomentStart
    i = 0

    while i < 7
      increment = if i != 0 then 1 else 0
      day = $scope.calMomentStart.add(increment, 'days')
      $scope.daysInWeek.push([day.format('ddd D MMM'), day.format("D-M-YYYY") ])
      i++

  setCalendarDays()

  $ ->
    #popup handler
    $('.fa-minus').on 'click', ->
      $(this).parents('.popup').find('ng-form').hide()
      $(this).hide()
      $(this).siblings('.fa-plus').show()

    $('.fa-plus').on 'click', ->
      $(this).parents('.popup').find('ng-form').show()
      $(this).hide()
      $(this).siblings('.fa-minus').show()

    $('.popup').draggable
      cursor: 'grabbing !important',
      opacity: 0.6

    #click on date box
    $('.shift-applicable').on 'click', ->
      return if $(this).children().find('.shift-bar').length > 0
      employeeID = $(this).parent('tr').data('employee-id')
      date       = $(this).data('date')
      $scope.newShift.date       = date
      $scope.newShift.employeeID = employeeID
      $scope.showNewPopup        = true
      $scope.$apply()


    #set leave bars
    for leave in $scope.leaves
      employeeID   = leave.employeeID
      employeeRow  = $('tr[data-employee-id="' + employeeID + '"]')
      employeeTD   = $(employeeRow).find('td.employee-name > span')
      if leave.fullDay
        leaveTDs = $(employeeRow).find('td:not(.employee-name)')

      else
        leaveTDs = $(employeeRow).find('td:not(.employee-name)').filter ()->
          return parseInt($(this).data('hour')) >= leave.startHour

      $(leaveTDs).each () ->
        $(this).css('background', 'whitesmoke').addClass('mark')


    $('.shift-applicable').each () ->
      day                       = $(this).data('day')
      left                      = $(this).offset().left
      # $scope.daysAndOffset[day] = left

    # Find top offset for each employee
    $("tbody tr").each () ->
      id                            = $(this).data("employee-id")
      top                           = $(this).offset().top
      $scope.employeesAndOffset[id] = top

app.filter 'acronymify', () ->
  return (input) ->
    return input.match(/\b(\w)/g).join('')


app.directive "shiftBar", ($timeout) ->
  restrict: 'A'
  require: 'ngModel'
  link: (scope, element, attrs) ->
    shift = scope[element.attr('ng-model')]

    setShift = ->
      tdWidth     = parseInt($('.shift-applicable').first().css('width'))
      tdHeight    = parseInt($('.shift-applicable').first().css('height'))
      shiftWidth  =  tdWidth - 15
      shiftHeight =  tdHeight - 10

      role       = shift.role
      shiftColor = scope.shiftColors[role]

      element.css('width', shiftWidth)
        .css('height', shiftHeight)
        .css('background-color', shiftColor)
        .css('border', '3px solid ' + shiftColor)
        .html('<span>' + shift.role + "<br/>" + shift.startHour + ':' + shift.startMin + '-' + shift.endHour + ':' + shift.endMin + "</span>")

      employeeID   = shift.employeeID
      employeeRow  =  $('tr[data-employee-id="' + employeeID + '"]')
      
      date            = shift.date
      shiftStartingUL = $(employeeRow).find('td[data-date=' +  date + '] .sortable')
      shiftStartingUL.append(element)

      return

    $timeout(setShift, 0)


toggleItemInArray = (array, value) ->
  index = array.indexOf(value)
  if index is -1
    array.push value
  else
    array.splice index, 1
  return

setShifts = (shiftColors)->
  tdWidth  = parseInt($('.shift-applicable').first().css('width'))
  tdHeight = parseInt($('.shift-applicable').first().css('height'))

  $('.shift-bar').each () ->
    shiftHours  =  $(this).data('length')
    shiftWidth  =  tdWidth - 10
    shiftHeight =  tdHeight - 10

    role       = $(this).data('role')
    shiftColor = shiftColors[role]

    $(this).css('width', shiftWidth).css('height', shiftHeight).css('background-color', shiftColor).css('border', '3px solid ' + shiftColor)

    employeeID   = $(this).data('employee-id')
    employeeRow  =  $('tr[data-employee-id="' + employeeID + '"]')
    
    date            = $(this).data('date')
    shiftStartingUL = $(employeeRow).find('td[data-date=' +  date + '] .sortable')
    $(this).appendTo(shiftStartingUL)
