app.directive 'calendarListener', () ->
  restrict: "A"
  link: (scope) ->
    $ ->
      $('.page-buttons').on 'click', '.summary-button',->
        $('summary .fa-plus').click()
        $.scrollTo($('summary').height() + 100, 300)

      #trash box functionality
      $('.rubbish-td').bind 'DOMNodeInserted', (event) ->
        shiftID = $(this).find('.shift-bar').data('shift-id')
        scope.func.removeShifts([shiftID])
        scope.$apply()

      $('.rubbish-td').bind 'click', ->
        if scope.data.toggledShifts.length > 0
          ifSuccess = ->
            scope.func.removeShifts(scope.data.toggledShifts)
            scope.$apply()
          scope.func.swal(ifSuccess, "Yes, delete!")

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

          for attr in scope.data.attrToClone
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
          scope.func.estimate()
          scope.$apply()

      #click on date box
      $('.shift-applicable').on 'click', ->
        return if $(this).children('.shift-bar').length > 0
        employeeID                     = $(this).parent('tr').data('employee-id')
        date                           = $(this).data('date')
        scope.data.newShift.date       = date
        scope.data.newShift.employeeID = employeeID
        scope.states.showNewPopup      = true
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

    setCalendarDays()
    $ ->
      setLeaveBars()
      scope.func.estimate()

app.directive 'popupHandler', () ->
  restrict: "A"
  link: (scope) ->
    $('i.fa-minus').on 'click', (e) ->
      e.preventDefault()
      $(this).parents('.expand-container').find('ng-form').hide()
      $(this).hide()
      $(this).siblings('.fa-plus').css('display', 'inline-block')

    $('i.fa-plus').on 'click', (e) ->
      e.preventDefault()
      $(this).parents('.expand-container').find('ng-form').show()
      $(this).hide()
      $(this).siblings('.fa-minus').css('display', 'inline-block')

    $('.popup, summary').draggable
      cursor: 'grabbing !important'
      opacity: 0.6

     $(document).on 'keyup', (e)->
       if e.keyCode is 27
         scope.states.showEditPopup = false
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
          if scope.data.toggledShifts.length > 0
            scope.states.isSelecting = true
          else
            scope.states.isSelecting = false

          scope.$apply()
          scope.func.toggled()


      rd.event.notCloned = ->
        console.log 'not cloned'

      rd.event.notMoved = ->
        if !(window.event.ctrlKey or window.event.metaKey)
          shiftID                  = $(rd.obj).data('shift-id')
          scope.data.selectedShift = scope.func.grabShift(shiftID)
          angular.copy(scope.data.selectedShift , scope.data.shiftCopy)

          scope.states.showEditPopup = true
          scope.$apply()

      rd.event.moved = ->
        console.log 'moved'
        shiftID                 = $(rd.obj).data('shift-id')
        shift                   = scope.func.grabShift(shiftID)
        angular.copy(shift, scope.data.baseShift)
        scope.states.isDragging = true

        if window.event.shiftKey is true
          # scope.data.tdToClone   = rd.td.source
          scope.states.isCloning = true

        scope.$apply()

      rd.event.dropped = ->
        console.log 'dropped'
        scope.states.isDragging = false
        scope.states.isCloning  = false
        scope.$apply()

      rd.event.notCloned = ->
        console.log 'notCloned'
        scope.states.isDragging = false
        scope.states.isCloning  = false
        scope.$apply()

      rd.event.deleted = (cloned) ->
        shift = scope.func.grabShift($(rd.td).data('shift-id'))
        index = scope.data.shifts.indexOf(shift)
        scope.states.isDragging  = false
        scope.shifts.splice(shift, 1)
        scope.$apply()
        console.log 'deleted'

      scope.states.isInitializing = false

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