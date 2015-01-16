window.app = app = angular.module "weekView", ['LocalForageModule', 'ui.select', 'ngSanitize']

app.config (uiSelectConfig) ->
  uiSelectConfig.theme = 'selectize'

app.controller "weekViewController", ($scope, $timeout, $http, $q) ->

  $scope.states =
    showEditPopup        : false
    showNewPopup         : false
    isCloning            : false
    isInitializing       : true
    showMenu             : false
    showHelp             : false
    showTemplateMenu     : false
    showSortMenu         : false
    isSavingTemplate     : false
    isUndoing            : false
    createForMultiple    : false
    showCommonTimingMenu : false
    metaKey              : false

  #init
  $scope.data =
    daysInWeek          : []
    toggledShifts       : []
    selectedShiftToEdit : {}
    shiftCopy           : {}
    baseShift           : {}
    attrToClone         : ['start','role','finish','break', 'employeeID', 'date', 'overnight']
    wageEstimate        : 0
    predicate           : 'id'
    newTemplateName     : ''
    templates           : []
    newTemplate         : {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [] }
    currentTemplate     : {}
    originalShifts      : []
    templateShifts      : []
    hoveredTemplate     : {}
    shiftStates         : []
    selectedTD          : ''
    commonTimings       : [{"id":1,"title":"Default",start: "08:00 AM",finish: "05:00 PM", break: 60}]

  $scope.data.calendarStartDate    = '4 Jan 2015'
  $scope.data.calMomentStart       = moment($scope.data.calendarStartDate, "D MMM YYYY")
  $scope.data.calMomentEnd         = moment($scope.data.calendarStartDate, "D MMM YYYY").add(6, 'days')
  $scope.data.calendarDisplayDate  = $scope.data.calMomentStart.format('ddd Do MMM YYYY') + " - " + $scope.data.calMomentEnd.format('ddd Do MMM YYYY')

  $scope.data.employees = [
    {id: '1', name: 'Fordon Ng', hoursExcludingThisWeek: 20, costPerHour: 10, totalHours: 40, currentWeekHours: 0, defaultRole: 'Manager'}
    {id: '2', name: 'Zadwin Feng', hoursExcludingThisWeek: 16, costPerHour: 7.5, totalHours: 40, currentWeekHours: 0, defaultRole: 'Crew'}
    {id: '3', name: 'Kan G', hoursExcludingThisWeek: 10, costPerHour: 7, totalHours: 35, currentWeekHours: 0, defaultRole: 'Asst Manager' }
    {id: '4', name: 'Lesslyn', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Asst Manager'}
    {id: '5', name: 'Zherwyn', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Supervisor'}
    {id: '6', name: 'Jebastian', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Supervisor'}
    # {id: '7', name: 'Bnonoz', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Crew' }
    # {id: '8', name: 'Zordon', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Supervisor'}
    # {id: '9', name: 'White Ranger', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Supervisor'}
    # {id: '10', name: 'Red Ranger', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Manager'}
    # {id: '11', name: 'Black Ranger', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Crew'}
    # {id: '12', name: 'Yellow Ranger', hoursExcludingThisWeek: 10, costPerHour: 12, totalHours: 35, currentWeekHours: 0, defaultRole: 'Crew'}
  ]

  $scope.data.shifts = []

  $scope.data.leaves = [
    {employeeID: '3', fullDay: false, startHour: 12}
    {employeeID: '4', fullDay: true, startHour: 12}
  ]

  $scope.data.shiftColors   = {'Manager': '#3498DB', 'Asst Manager': '#2ECC71', 'Supervisor': '#9B59B6', 'Crew': '#F39C12'}
  $scope.data.roles         = ["Manager", "Asst Manager", "Supervisor", "Crew"]

  $scope.data.salesForecast    = "2000"
  $scope.data.budgetPercentage = "15"
  $scope.data.wageBudget       =  ($scope.data.salesForecast/100) *  $scope.data.budgetPercentage

  $scope.$watchGroup ['data.salesForecast', 'data.budgetPercentage'], (newVal, oldVal, scope) ->
    scope.data.wageBudget       =  ($scope.data.salesForecast/100) *  $scope.data.budgetPercentage

  $scope.$watch 'states.showNewPopup', (newVal, oldVal, scope) ->
    $scope.states.createForMultiple = false
    if newVal
      $scope.states.showEditPopup        = false
      $scope.states.showCommonTimingMenu = false
      $scope.func.setNewShift()
      $scope.func.hideMenus()

  $scope.$watch 'states.showEditPopup', (newVal, oldVal, scope) ->
    if newVal
      $scope.states.showNewPopup         = false
      $scope.states.showCommonTimingMenu = false
      $scope.func.hideMenus()

  $scope.$watch 'states.showCommonTimingMenu', (newVal, oldVal, scope) ->
    if newVal
      $scope.states.showNewPopup  = false
      $scope.states.showEditPopup = false
      $('#commonTimingMenu').trigger 'show'
      $scope.func.hideMenus()

  $scope.$watch 'states.isSavingTemplate', (newValue, oldValue, scope) ->
    if newValue
      focusInput = ->
        $('input.template-name').focus()
      $timeout(focusInput, 0)

  $scope.$watch 'states.isCloning', (newVal, oldVal, scope) ->
    unless newVal
      scope.data.baseShift = {}

  $scope.$watchCollection 'data.shifts', (newVal, oldVal, scope) ->
    unless $scope.states.isUndoing
      console.log 'storing state'
      shifts = []
      angular.copy(newVal, shifts)
      $scope.data.shiftStates.push(shifts)
      $scope.data.shiftStates.pop() if $scope.data.shiftStates.length > 20

      unless $scope.states.isInitializing
        localforage.setItem('shifts', angular.toJson($scope.data.shifts) )
        console.log 'setting localForage shifts'

  $scope.$watchCollection 'data.commonTimings', (newVal, oldVal, scope) ->
    unless $scope.states.isInitializing
      localforage.setItem('commonTimings', angular.toJson(newVal))
      console.log 'setting localForage commonTimings'

  $scope.func =
    setNewShift: ->
      console.log 'settingNewShift'
      $scope.data.newShift = {role: $scope.data.roles[$scope.data.roles.length - 1], break: 30, start: '08:00 AM', finish: '05:00 PM', overnight: false}

    updateEndTime: (object) ->
      object         = $scope.data[object]
      start          = moment(object.date + object.start, 'D MMM YYYYhh:mm A')
      finish         = start.add(object.durationHours, 'h').add(object.durationMins, 'm')
      object.endHour = finish.format('hh')
      object.endMin  = finish.format('mm')

    setShifts: ->
      console.log 'setting shifts'
      for shift in $scope.data.shifts
        shift.id = $scope.data.shifts.indexOf(shift) + 1
      $scope.$apply()
      $scope.$broadcast 'setShift'

    setCommonTiming: (commonTimingID, shift) ->
      for timing in $scope.data.commonTimings
        if parseInt(timing.id) is parseInt(commonTimingID)
          angular.forEach ['start','finish', 'break', 'overnight'], (val, key) ->
            $scope.data[shift][val] = timing[val]

    undo: () ->
      console.log 'undoing'
      $scope.data.shifts = []
      #last state
      shiftStatesCount = $scope.data.shiftStates.length
      stateToRevertTo  = $scope.data.shiftStates[shiftStatesCount - 2]
      angular.copy(stateToRevertTo, $scope.data.shifts)
      #remove current state, undo currently without redo
      $scope.data.shiftStates.pop()
      $timeout($scope.func.refreshCalendar, 0)

    hideMenus: () ->
      $scope.states.showMenu             = false
      $scope.states.showTemplateMenu     = false
      # $scope.func.resetSelected()

    convertToTemplate: (shifts, name) ->
      template      = {}
      angular.copy($scope.data.newTemplate, template)
      template.name = name
      #sort shifts into days, and place to 1, which is monday, 2 = tueday, and so on
      for shift in shifts
        dayInteger       = moment(shift.date, 'D MMM YYYY').format('d') #starts at 0 for sunday, 1 for monday
        shift.dayInteger = dayInteger
        template[dayInteger].push(shift)

      return template

    saveTemplate: (name)->
      newTemplate                 = {}
      newTemplate                 = $scope.func.convertToTemplate($scope.data.shifts, name)
      $scope.data.templates.push(newTemplate)

      swal
        title: 'Template ' + newTemplate.name + " has been saved!"
        timer: 1000

      $scope.data.newTemplateName    =  ''
      $scope.states.isSavingTemplate = $scope.states.showTemplateMenu = false

    loadTemplate: (templateName) ->
      for template in $scope.data.templates
        if template.name is templateName
          $scope.data.currentTemplate = template

      $scope.func.copyShifts($scope.data.calendarStartDate, $scope.data.currentTemplate)

      ifSuccess = ->
        $scope.data.shifts = []
        angular.copy($scope.data.templateShifts, $scope.data.shifts)
        $scope.func.resetSelected()
        $timeout($scope.func.refreshCalendar, 0)
        $scope.data.templateShifts = []
        $scope.$apply()

      $scope.func.swal(ifSuccess, "Yes, revert to template!", '#F1C40F')

    deleteTemplate: (template) ->
      window.event.stopPropagation()
      ifSuccess = ->
        index = $scope.data.templates.indexOf(template)
        $scope.data.templates.splice(index, 1)
        $scope.$apply()

      $scope.func.swal(ifSuccess, "Yes, delete template!")

    copyShifts: (startDate, template) ->
      calendarDays = {0: '', 1: '', 2: '', 3: '',4: '', 5: '',6: ''}

      i = 0
      while i < 8
        calendarDays[i] = moment(startDate, "D MMM YYYY").add(i, 'days').format("D MMM YYYY")
        i++

      angular.forEach [0,1,2,3,4,5,6], (dayInteger) ->
        for shift in template[dayInteger]
          shift.date     = calendarDays[dayInteger]
          shiftToPush    = angular.copy(shift)
          shiftToPush.id = $scope.data.templateShifts.length + 1
          $scope.data.templateShifts.push(shiftToPush)

    goToSummary: ->
      $('summary .fa-plus').click()
      $.scrollTo($('summary').offset().top - 120, 300)

    estimate: ->
      console.log 'estimating wagecost and setting employee current working hours'
      $scope.data.wageEstimate = 0
      for employee in $scope.data.employees
        employee.currentWeekHours = 0

      for day in $scope.data.daysInWeek
        day[2]    = day[3] = 0
        shiftBars = $('.shift-bar[data-date="' + day[1] + '"]')
        angular.forEach shiftBars, (shiftBar) ->
          shift     = $scope.func.grabShift($(shiftBar).data('shift-id'))
          employee  = $scope.func.grabEmployee(shift.employeeID)

          if shift.overnight
            finish    = moment(shift.finish, 'hh:mm A').add(1, 'days')
          else
            finish    = moment(shift.finish, 'hh:mm A')

          length    = (finish - moment(shift.start, 'hh:mm A'))/3600000 - shift.break/60
          wageCost  = parseInt(employee.costPerHour) * length
          day[2]    += wageCost
          day[3]    += length

          $scope.data.wageEstimate  += wageCost

          employee.currentWeekHours += parseInt(length)

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
          $scope.states.showEditPopup = false

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
      $scope.data.shiftCopy =  angular.copy($scope.data.selectedShiftToEdit)
      $scope.$apply()

    grabEmployee: (employeeID) ->
      for employee in $scope.data.employees
        return employee if parseInt(employee.id) is parseInt(employeeID)

    grabShift: (shiftID) ->
      for shift in $scope.data.shifts
        return shift if parseInt(shift.id) is parseInt(shiftID)

    updateShift: (shiftCopy) ->
      shiftToUpdate = $scope.data.selectedShiftToEdit

      attrToClone    = $scope.data.attrToClone
      for attr in attrToClone
        shiftToUpdate[attr] = shiftCopy[attr]

      $scope.func.updateShiftColor(shiftToUpdate)
      $scope.data.selectedShiftToEdit = {}
      $scope.states.showEditPopup     = false
      $timeout($scope.func.refreshCalendar, 0)
      $scope.func.toggled()
      localforage.setItem('shifts', angular.toJson($scope.data.shifts) )

    resetSelected: ->
      $scope.data.toggledShifts = []
      $scope.func.toggled()

    createFromPopup: ->
      shiftToPush = {}
      angular.copy($scope.data.newShift, shiftToPush)
      shiftToPush = $scope.func.setID(shiftToPush)
      $scope.data.shifts.push(shiftToPush)

      #reset new shift and close popup
      $timeout($scope.func.refreshCalendar, 0)
      $scope.states.showNewPopup = false
      $scope.func.setNewShift()

    createMultipleFromPopup: ->
      for day in $scope.data.daysInWeek
        if day[4]
          shiftToPush = {}
          angular.copy($scope.data.newShift, shiftToPush)
          shiftToPush.date = day[1]
          shiftToPush      = $scope.func.setID(shiftToPush)
          $scope.data.shifts.push(shiftToPush)
      $scope.data.newShift          = {role: $scope.data.roles[0], start: '08:00 AM', finish: '05:00 PM', break: 60}
      $scope.states.showNewPopup    = false
      $scope.data.createForMultiple = false
      $scope.func.resetSelected()
      $timeout($scope.func.refreshCalendar, 0)

    submitShift: (shift) ->
      shift = $scope.func.setID(shift)
      $scope.data.shifts.push(shift)
      $scope.data.baseShift = {}
      $scope.$apply()
      $timeout($scope.func.refreshCalendar, 0)

    setID: (shift) ->
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

    removeToggled: ->
      ifSuccess = ->
        $scope.func.removeShifts($scope.data.toggledShifts)
        $scope.$apply()
      $scope.func.swal(ifSuccess, "Yes, delete!")

    refreshCalendar: ->
      console.log 'refreshing calendar'
      $scope.func.setShifts()
      REDIPS.drag.init('week-view')
      $scope.func.estimate()
      $('table').trigger 'deselect'

    loadData: ->
      defer = $q.defer()
      $http.post("/week_view_manager",
        date: $scope.data.calendarStartDate
        shifts: $scope.data.shifts
      ).success((data, status, headers, config) ->
        defer.resolve(data)
      ).error (error, status, headers, config) ->
        defer.reject(error)

      return defer.promise

    publish: ->
      $scope.func.loadData().then( (data) ->
        console.log 'todo'
      , (error) ->
        console.log 'error'
      )

      # ifSuccess = ->
      #   console.log 'todo'
      # $scope.func.swal(ifSuccess, "Yes, publish!",'#2ECC71', 'success')

app.filter 'acronymify', () ->
  return (input) ->
    return input.match(/\b(\w)/g).join('')