app.directive 'calendarListener', () ->
  restrict: "A"
  link: (scope) ->
    $ ->
      #trash box functionality
      $('.rubbish-td').bind 'DOMNodeInserted', (event) ->
          shiftID = $(this).find('.shift-bar').data('shift-id')
          scope.func.removeShifts([shiftID])
          scope.$apply()

      #clone shift or move shift
      $('.shift-applicable').bind 'DOMNodeInserted ', (event) ->
        console.log 'dom node inserted'
        return if scope.states.isInitializing
        date           = $(this).data('date')
        employeeID     = $(this).parent().data('employee-id')
        shiftBeforeMod = scope.data.baseShift
        if scope.states.isCloning
          # make a new shift where clone is at and submit, remove cloned div
          newShift = {}

          attrToClone    = ['startHour','startMin','role','endHour','endMin','breakHours']

          for attr in attrToClone
            newShift[attr] = shiftBeforeMod[attr]

          newShift.date       =  date

          newShift.employeeID = employeeID

          scope.func.submitShift(newShift)
          $('.shift-bar[data-shift-id="' + shiftBeforeMod.id + '"]').first().remove()
          # We allow angular directives to create this clone
        else
          console.log 'modifying previous'
          shiftBeforeMod.date       = date
          shiftBeforeMod.employeeID = employeeID
          scope.$apply()

      #click on date box
      $('.shift-applicable').on 'click', ->
        return if $(this).children('.shift-bar').length > 0
        employeeID = $(this).parent('tr').data('employee-id')
        date       = $(this).data('date')
        scope.data.newShift.date       = date
        scope.data.newShift.employeeID = employeeID
        scope.states.showNewPopup        = true

        scope.$apply()


app.directive 'calendarSetup', () ->
  restrict: 'A'
  link: (scope) ->
    setCalendarDays = ->
      #set the calendar start and end times
      min = scope.data.calMomentStart
      i = 0
      while i < 7
        increment = if i != 0 then 1 else 0
        day = scope.data.calMomentStart.add(increment, 'days')
        scope.data.daysInWeek.push([day.format('ddd D MMM'), day.format("D-M-YYYY") ])
        i++

    setLeaveBars = ->
      for leave in scope.data.leaves
        employeeID   = leave.employeeID
        employeeRow  = $('tr[data-employee-id="' + employeeID + '"]')
        employeeTD   = $(employeeRow).find('td.employee-name > span')
        if leave.fullDay
          leaveTDs = $(employeeRow).find('td:not(.employee-name)')

        else
          leaveTDs = $(employeeRow).find('td:not(.employee-name)').filter ()->
            return parseInt($(this).data('hour')) >= leave.startHour

        $(leaveTDs).each () ->
          $(this).css('background', 'lightgrey').addClass('mark')

    scope.func.refreshCalendar = ->
      console.log 'refreshing calendar'
      for shift in scope.data.shifts
        employeeID      = shift.employeeID
        employeeRow     = $('tr[data-employee-id="' + employeeID + '"]')
        shiftStartingUL = $(employeeRow).find('td[data-date=' +  shift.date + ']')
        element         = $('.shift-bar[data-shift-id="' + shift.id + '"]')
        shiftStartingUL.append(element)

      REDIPS.drag.init('week-view')
      scope.states.isInitializing = false


    setCalendarDays()
    $ ->
      setLeaveBars()

app.directive 'popupHandler', () ->
  restrict: "A"
  link: (scope) ->
    $('.fa-minus').on 'click', ->
      $(this).parents('.expand-container').find('ng-form').hide()
      $(this).hide()
      $(this).siblings('.fa-plus').css('display', 'inline-block')

    $('.fa-plus').on 'click', ->
      $(this).parents('.expand-container').find('ng-form').show()
      $(this).hide()
      $(this).siblings('.fa-minus').css('display', 'inline-block')

    $('.popup').draggable
      cursor: 'grabbing !important'
      opacity: 0.6

     $(document).on 'keyup', (e)->
       if e.keyCode is 27
         scope.states.showEditPopup     = false
         scope.states.showNewPopup  = false
         scope.func.resetSelected()
         scope.$apply()

app.directive 'shiftBar', ($timeout) ->
  restrict: 'A'
  require: 'ngModel'
  link: (scope, element, attrs) ->
    shiftID = attrs.shiftId
    shift   = scope.func.grabShift(shiftID)

    scope.func.updateShiftColor = (shift) ->
      #find shift bar and update color
      shiftBar = $('.shift-bar[data-shift-id="' + shift.id + '"]')
      shiftColor = scope.data.shiftColors[shift.role]
      shiftBar.css('color', shiftColor)
        .css('border', '3px solid ' + shiftColor)
        .html('<span>' + shift.role + "<br/>" + shift.startHour + ':' + shift.startMin + ' - ' + shift.endHour + ':' + shift.endMin + "</span>")
      return

    setShift = ->
      console.log 'setting shift'
      tdWidth     = parseInt($('.shift-applicable').first().css('width'))
      tdHeight    = parseInt($('.shift-applicable').first().css('height'))
      shiftWidth  =  '130px'
      shiftHeight =  '45px'

      role       = shift.role
      shiftColor = scope.data.shiftColors[role]

      element.css('min-width', shiftWidth)
        .css('min-height', shiftHeight)
        .css('color', shiftColor)
        .css('border', '3px solid ' + shiftColor)
        .html('<span>' + shift.role + "<br/>" + shift.startHour + ':' + shift.startMin + ' - ' + shift.endHour + ':' + shift.endMin + "</span>")

      employeeID   = shift.employeeID
      employeeRow  =  $('tr[data-employee-id="' + employeeID + '"]')

      date            = shift.date
      shiftStartingUL = $(employeeRow).find('td[data-date=' +  date + ']')
      shiftStartingUL.append(element)

    $timeout(setShift, 0)


app.directive 'setDrag', ($timeout) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    redipsInit = ->
      rd = REDIPS.drag
      rd.init('week-view')
      rd.hover.colorTd  = 'blank'
      rd.hover.borderTd = '3px solid #9bb3da'
      rd.clone.keyDiv   = true
      rd.trash.question = 'Are you sure you want to delete this shift?'

      rd.event.clicked = (currentCell)->
        console.log 'clicked'
        if window.event.metaKey
          shiftID            = $(rd.obj).data('shift-id')
          toggleItemInArray(scope.data.toggledShifts, shiftID)
          scope.states.isSelecting = if scope.data.toggledShifts.length > 0 then true else false
          scope.$apply()
          scope.func.toggled()


      rd.event.notCloned = ->
        console.log 'not cloned'

      rd.event.notMoved = ->
        if !(window.event.ctrlKey or window.event.metaKey)
          shiftID                    = $(rd.obj).data('shift-id')
          angular.copy(scope.func.grabShift(shiftID), scope.data.selectedShift)
          scope.states.showEditPopup = true
          scope.$apply()

      rd.event.moved = ->
        console.log 'moved'
        shiftID                     = $(rd.obj).data('shift-id')
        shift                       = scope.func.grabShift(shiftID)
        scope.data.baseShift        = shift

        if window.event.shiftKey is true
          scope.data.tdToClone     = rd.td.source
          scope.states.isCloning     = true
          scope.$apply()

      rd.event.dropped = ->
        console.log 'dropped'
        scope.states.isCloning     = false
        scope.$apply()

      rd.event.notCloned = ->
        console.log 'notCloned'
        scope.states.isCloning = false
        scope.$apply()

      rd.event.deleted = (cloned) ->
        shift = scope.func.grabShift($(rd.td).data('shift-id'))
        index = scope.data.shifts.indexOf(shift)
        scope.shifts.splice(shift, 1)
        scope.$apply()
        console.log 'deleted'

    # add onload event listener
    if window.addEventListener
      window.addEventListener "load", redipsInit, false
    else window.attachEvent "onload", redipsInit  if window.attachEvent

toggleItemInArray = (array, value) ->
  index = array.indexOf(value)
  if index is -1
    array.push value
  else
    array.splice index, 1
  return