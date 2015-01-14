app.directive 'calendarListener', () ->
  restrict: "A"
  link: (scope) ->
    $ ->
      $('#commonTimingMenu').on 'show', ->
        $(this).find('ng-form').show()

      $('body').on 'mouseover', '.commonTiming-button', ->
        ID  = $(this).data('timing-id')
        for commonTiming in scope.data.commonTimings
          timing = commonTiming if commonTiming.id is ID
        text   = timing.startHour + ':' + timing.startMin + ' - ' + timing.endHour + ':' + timing.endMin
        $(this).text(text)

      $('body').on 'mouseleave', '.commonTiming-button', ->
        ID  = $(this).data('timing-id')
        for commonTiming in scope.data.commonTimings
          timing = commonTiming if commonTiming.id is ID
        text   = timing.startHour + ':' + timing.startMin + ' - ' + timing.endHour + ':' + timing.endMin
        $(this).text(timing.title)

      $('table').on 'deselect',  ->
        $('td.selected').removeClass('selected')

      $('.page-buttons').on 'click', '.summary-button',->
        scope.func.goToSummary()

      #clone shift or move shift
      $('.shift-applicable').bind 'DOMNodeInserted ', (event) ->
        console.log 'dom node inserted'
        return if scope.states.isInitializing
        date           = $(this).data('date')
        employeeID     = $(this).data('employee-id')
        shiftBeforeMod = scope.data.baseShift

        if scope.states.isCloning
          # make a new shift where clone is at and submit, remove cloned div
          newShift = {}
          angular.copy(shiftBeforeMod, newShift)
          newShift.date       =  date
          newShift.employeeID = employeeID
          scope.func.submitShift(newShift)
          $(event.target).remove()
          # We allow angular directives to create this clone
        else
          console.log 'modifying previous'
          shiftBeforeMod.date       = date
          shiftBeforeMod.employeeID = employeeID
          scope.$apply()
          scope.func.estimate()

      #click on date box
      $('.shift-applicable').on 'click', ->
        return if $(this).children('.shift-bar').length > 0
        employeeID                     = $(this).parent('tr').data('employee-id')
        date                           = $(this).data('date')
        scope.data.newShift.date       = date
        scope.data.newShift.employeeID = employeeID
        $('td.selected').removeClass('selected')
        $(this).addClass('selected')

        #Reset for creating multiple
        for day in scope.data.daysInWeek
          day[4] = false
        dayInteger = moment($(this).data('date'), "DD-MM-YYYY").format('d')
        scope.data.daysInWeek[dayInteger][4] = true

        scope.states.showNewPopup            = true
        scope.$apply()

        tdOffset      = $(this).offset()
        tdOffset.top  += parseInt($(this).css('height'))/2
        tdOffset.left += parseInt($(this).css('width'))/2
        $('.popup').trigger 'reposition', [tdOffset]
        $('#newPopup').find('ng-form').show()


app.directive 'calendarSetup', ($timeout) ->
  restrict: 'A'
  link: (scope) ->
    setCalendarDays = ->
      #set the calendar start and end times
      min = scope.data.calMomentStart
      i = 0
      while i < 7
        increment = if i != 0 then 1 else 0
        day = scope.data.calMomentStart.add(increment, 'days')
        #undefined are for estimations, d is for weekday integer, boolean is for whether to multi-create for this day
        scope.data.daysInWeek.push([day.format('ddd D MMM'), day.format("DD-MM-YYYY"), undefined, undefined, false])
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

    setDraggableArea = ->
      height = $('.draggable-area').height()
      $('.draggable-area').height(height + 400)
    setCalendarDays()

    $ ->
      setLeaveBars()
      setDraggableArea()
      scope.func.estimate()

      $(window).on 'load', ->
        localforage.getItem 'shifts', (err, value) ->
          if value
            scope.data.shifts    = JSON.parse(value)
            angular.copy(scope.data.shifts, scope.data.originalShifts)
            $timeout(scope.func.refreshCalendar, 0)

        localforage.getItem 'commonTimings', (err, value) ->
          if value
            scope.data.commonTimings    = JSON.parse(value)
            scope.$apply()


app.directive 'popupHandler', ($timeout) ->
  restrict: "A"
  link: (scope) ->
    $('.popup').on 'reposition', (e, tdOffset) ->
      windowWidth     = $(window).width()
      windowHeight    = $(window).height()
      spaceFromLeft   = windowWidth - tdOffset.left
      spaceFromBottom = windowHeight - tdOffset.top

      if spaceFromLeft < 500
        tdOffset.left += -600 + windowWidth - tdOffset.left
      if spaceFromBottom < 300
        tdOffset.top += -400 + windowHeight - tdOffset.top

      move = ->
        $('#newPopup, #editPopup').offset(tdOffset)
      $timeout(move, 0)

    $('i.fa-minus').parents('.btn').on 'click', ->
      $(this).parents('.expand-container').find('ng-form').hide()

    $('i.fa-plus').parents('.btn').on 'click', ->
      $(this).parents('.expand-container').find('ng-form').show()

    $('.popup, summary, .commands-list').draggable
      cursor: 'grabbing !important'
      containment: '.draggable-area'
      opacity: 0.6

    #commonTiming handler
    $('body').on 'click', ('#addNewCommonTiming'),  ->
      newCommonTiming = {
        id        : scope.data.commonTimings.length + 1
        title     : 'Standard'
        startHour : '08'
        startMin  : '00'
        endHour   : '17'
        endMin    : '00'
      }
      scope.data.commonTimings.push(newCommonTiming)
      scope.$apply()

    $('body').on 'click', ('#removeCommonTiming'), ->
      commonTimingID = $(this).data('common-timing-id')
      for shift in scope.data.commonTimings
        if shift.id is commonTimingID
          index = scope.data.commonTimings.indexOf(shift)
          scope.data.commonTimings.splice(index, 1)
      scope.$apply()

     $(window).on 'keyup', (e)->
      if e.keyCode is 27
        angular.forEach scope.states, (state, key) ->
          scope.states[key] = false
        $('.fa-minus').click()
        scope.func.resetSelected()
        $('table').trigger 'deselect'

      if e.keyCode is 112
        scope.states.showHelp =  !scope.states.showHelp

      scope.states.metaKey = false
      scope.$apply()


    $(window).on 'keydown', (e) ->
      return if $(e.target).is('input')
      if (e.shiftKey)
        if e.keyCode is 83
          scope.func.goToSummary()

        if e.keyCode is 78
          scope.states.showNewPopup = true
          $('#newPopup').find('ng-form').show()
          scope.$apply()

        if e.keyCode is 82
          scope.func.resetShifts()

        if e.keyCode is 80
          scope.func.publish()

      if e.metaKey
        scope.states.metaKey = true
        scope.$apply()

        if e.keyCode is 90
          scope.states.isUndoing = true
          $('.fa-undo').click()
          stopUndo = ->
            scope.states.isUndoing = false
          $timeout(stopUndo, 0)


      return if $(document.activeElement).is('input')
      if (e.keyCode is 8) or (e.keyCode is 46)
        e.preventDefault()
        if e.shiftKey
          scope.func.deleteAll()
        if scope.data.toggledShifts.length > 0
          scope.func.removeToggled()



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

    scope.$on 'setShift', ->
      console.log 'setting shift'
      tdWidth     = parseInt($('.shift-applicable').first().css('width'))
      tdHeight    = parseInt($('.shift-applicable').first().css('height'))
      shiftWidth  = '130px'
      shiftHeight = '45px'

      role       = shift.role
      shiftColor = scope.data.shiftColors[role]

      element.css('min-width', shiftWidth)
        .css('min-height', shiftHeight)
        .css('color', shiftColor)
        .css('background', 'white')
        .css('border', '3px solid ' + shiftColor)
        .css('display', 'inline-block')
        .html('<span>' + shift.role + "<br/>" + shift.startHour + ':' + shift.startMin + ' - ' + shift.endHour + ':' + shift.endMin + "</span>")

      employeeID   = shift.employeeID
      employeeRow  =  $('tr[data-employee-id="' + employeeID + '"]')

      date            = shift.date
      shiftStartingUL = $(employeeRow).find('td[data-date="' +  date + '"]')
      shiftStartingUL.append(element)


app.directive 'setDrag', ($timeout) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    redipsInit = ->
      rd = REDIPS.drag
      rd.init('week-view')
      rd.hover.colorTd  = 'aliceblue'
      # rd.hover.borderTd = '3px solid #9bb3da' causes firefox issues
      rd.clone.keyDiv   = true

      rd.event.clicked = (currentCell)->
        console.log 'clicked'
        if scope.states.metaKey
          shiftID = $(rd.obj).data 'shift-id'
          toggleItemInArray scope.data.toggledShifts, shiftID
          scope.func.toggled()
          scope.$apply()

      # rd.event.notCloned = ->
      #   console.log 'not cloned'

      rd.event.notMoved = ->
        if !scope.states.metaKey
          shiftID                        = $(rd.obj).data 'shift-id'
          shift                          = scope.func.grabShift shiftID
          scope.data.selectedShiftToEdit = shift
          angular.copy scope.data.selectedShiftToEdit , scope.data.shiftCopy

          $('table').trigger 'deselect'
          $(rd.td.current).addClass 'selected'

          scope.states.showEditPopup = true
          popup                      = $(rd.obj)
          tdOffset                   = popup.offset()
          tdOffset.top               += parseInt(popup.css('height'))/2
          tdOffset.left              += parseInt(popup.css('width'))/2
          $('.popup').trigger 'reposition', [tdOffset]
          $('#editPopup').find('ng-form').show()
          scope.func.resetSelected()
          if scope.data.toggledShifts.indexOf(shiftID) is -1
            console.log 'pushing shift into toggled'
            scope.data.toggledShifts.push(shiftID)
          scope.func.toggled()
          scope.$apply()

      rd.event.moved = (cloned) ->
        console.log 'moved'
        shiftID                 = $(rd.obj).data('shift-id')
        scope.data.baseShift    = scope.func.grabShift(shiftID)
        scope.states.isDragging = true
        scope.states.isCloning  = cloned
        scope.$apply()

      rd.event.dropped = ->
        console.log 'dropped'
        scope.data.baseShift    = {}
        scope.states.isDragging = false
        scope.states.isCloning  = false
        scope.$apply()

      rd.event.notCloned = ->
        console.log 'notCloned'
        scope.data.baseShift    = {}
        scope.states.isDragging = false
        scope.states.isCloning  = false
        scope.$apply()

      scope.states.isInitializing = false
      scope.func.refreshCalendar

    # add onload event listener
    if window.addEventListener
      window.addEventListener "load", redipsInit, false
    else window.attachEvent "onload", redipsInit  if window.attachEvent


app.directive "ngCurrency", [
  "$filter"
  "$locale"
  ($filter, $locale) ->
    return (
      require: "ngModel"
      scope:
        min: "=min"
        max: "=max"
        currencySymbol: "@"
        ngRequired: "=ngRequired"

      link: (scope, element, attrs, ngModel) ->
        decimalRex = (dChar) ->
          RegExp "\\d|\\-|\\" + dChar, "g"
        clearRex = (dChar) ->
          RegExp "\\-{0,1}((\\" + dChar + ")|([0-9]{1,}\\" + dChar + "?))&?[0-9]{0,2}", "g"
        clearValue = (value) ->
          value = String(value)
          dSeparator = $locale.NUMBER_FORMATS.DECIMAL_SEP
          cleared = null
          value = "-0"  if RegExp("^-[\\s]*$", "g").test(value)
          if decimalRex(dSeparator).test(value)
            cleared = value.match(decimalRex(dSeparator)).join("").match(clearRex(dSeparator))
            cleared = (if cleared then cleared[0].replace(dSeparator, ".") else null)
          else
            cleaned = null
          cleared
        currencySymbol = ->
          return ''
          if angular.isDefined(scope.currencySymbol)
            scope.currencySymbol
          else
            $locale.NUMBER_FORMATS.CURRENCY_SYM
        runValidations = (cVal) ->
          return  if not scope.ngRequired and isNaN(cVal)
          if scope.min
            min = parseFloat(scope.min)
            ngModel.$setValidity "min", cVal >= min
          if scope.max
            max = parseFloat(scope.max)
            ngModel.$setValidity "max", cVal <= max
          return
        ngModel.$parsers.push (viewValue) ->
          cVal = clearValue(viewValue)
          parseFloat cVal

        element.on "blur", ->
          element.val $filter("currency")(ngModel.$modelValue, currencySymbol())
          return

        ngModel.$formatters.unshift (value) ->
          $filter("currency") value, currencySymbol()

        scope.$watch (->
          ngModel.$modelValue
        ), (newValue, oldValue) ->
          runValidations newValue
          return
        return
    )
]


toggleItemInArray = (array, value) ->
  index = array.indexOf(value)
  if index is -1
    array.push value
  else
    array.splice index, 1
  return