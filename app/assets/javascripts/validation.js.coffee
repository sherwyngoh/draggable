# app.js
# create angular app
app = angular.module("validationApp", [])

# create angular controller
app.controller "MainController", ($scope) ->

  $scope.submitForm = (isValid) ->
    alert "our form is amazing"  if isValid
    return

  $scope.isValidNRIC = (entry) ->
    return false unless entry? and entry.length is 9

    [weights, total, count, nricNumbers, initialLetter, lastLetter] = [[2, 7, 6, 5, 4, 3, 2], 0, 0, parseInt(entry.substr(1,entry.length - 2)), entry[0], entry.substr(-1)]

    return false  if (initialLetter isnt "S" and initialLetter isnt "T") or isNaN(nricNumbers)

    until nricNumbers is 0
      total += (nricNumbers % 10) * weights[weights.length - (1 + count++)]
      nricNumbers /= 10
      nricNumbers = Math.floor(nricNumbers)

    outputs = if initialLetter is "S" then ["J", "Z", "I", "H", "G", "F", "E", "D", "C", "B", "A"] else ["G", "F", "E", "D", "C", "B", "A", "J", "Z", "I", "H"]

    return false unless lastLetter is outputs[total % 11]
    return true

  $scope.isValidFIN = (entry) ->
    multiples = [2, 7, 6, 5, 4, 3, 2]
    return false  unless fin? and fin.length == 9
    [weights, total, count, nricNumbers, initialLetter, lastLetter] = [[2, 7, 6, 5, 4, 3, 2], 0, 0, parseInt(entry.substr(1,entry.length - 2)), entry[0], entry.substr(-1)]
    return false  if initialLetter isnt "F" and initialLetter isnt "G"

    return false  if isNaN(nricNumbers)

    until nricNumbers is 0
      total += (nricNumbers % 10) * weights[weights.length - (1 + count++)]
      nricNumbers /= 10
      nricNumbers = Math.floor(nricNumbers)

    outputs = if (initialLetter is "F") then ["X", "W", "U", "T", "R", "Q", "P", "N", "M", "L", "K"] else ["R", "Q", "P", "N", "M", "L", "K", "X", "W", "U", "T"]
    return false unless lastLetter is outputs[total%11]
  return

app.directive "blacklist", ->
  require: "ngModel"
  link: (scope, elem, attr, ngModel) ->
    blacklist = attr.blacklist.split(",")
    
    #For DOM -> model validation
    ngModel.$parsers.unshift (value) ->
      valid = blacklist.indexOf(value) is -1
      ngModel.$setValidity "blacklist", valid
      (if valid then value else `undefined`)

    
    #For model -> DOM validation
    ngModel.$formatters.unshift (value) ->
      ngModel.$setValidity "blacklist", blacklist.indexOf(value) is -1
      value

    return

app.directive "myValidateAirportCode", ->
  
  # requires an isloated model
  
  # restrict to an attribute type.
  restrict: "A"
  
  # element must have ng-model attribute.
  require: "ngModel"
  link: (scope, ele, attrs, ctrl) ->
    
    # add a parser that will process each time the value is
    # parsed into the model when the user updates it.
    ctrl.$parsers.unshift (value) ->
      if value
        
        # test and set the validity after update.
        valid = value.charAt(0) is "A" or value.charAt(0) is "a"
        ctrl.$setValidity "invalidAiportCode", valid
      
      # if it's valid, return the value to the model,
      # otherwise return undefined.
      (if valid then value else `undefined`)

    return

app.directive "autoCapitalize", ($parse) ->
  require: "ngModel"
  link: (scope, element, attrs, ctrl) ->
    capitalize = (inputValue) ->
      inputValue = ""  if inputValue is `undefined`
      capitalized = inputValue.toUpperCase()
      if capitalized isnt inputValue
        ctrl.$setViewValue capitalized
        ctrl.$render()
      capitalized

    ctrl.$parsers.push capitalize
    capitalize $parse(attrs.ngModel)(scope) # capitalize initial value
    return

# app.directive "validateNric", ($parse) ->
#   restrict: "A"
#   require: "ngModel"
#   scope: true
#   link: (scope, element, attrs, ctrl) ->
#     ctrl.$parsers.unshift (entry) ->
#       if entry
#         # test and set the validity after update.
#         valid = scope.isValidNRIC(value)
#         ctrl.$setValidity "invalidNRIC", valid
      
#       # if it's valid, return the value to the model,
#       if valid then value else `undefined`
#     return
#   return