$(document).ready ->
  $(".drop").droppable tolerance: "fit"

  $(".drag").draggable
    revert: "invalid"
    stop: ->
      $(this).draggable "option", "revert", "invalid"
      console.log($(this).offset().left)
      oneSixth     = $(window).width()/6
      divOffset    = $(this).offset().left
      currentLevel = $(this).data('level')
      [newLevel, newTitle]     =
        if divOffset > (oneSixth*5)
          ['6', 'Trainee']
        else if divOffset > (oneSixth*4)
          ['5', 'Crew']
        else if divOffset > (oneSixth*3)
          ['4', 'Team Leader']
        else if divOffset > (oneSixth*2)
          ['3', 'Supervisor']
        else if divOffset > (oneSixth)
          ['2', 'Assistant Manager']
        else
          ['1', 'Manager']


      personName   = $(this).text()
      if currentLevel != newLevel
        $(this).data('level', newLevel)
        $(this).removeClass("level-" + currentLevel).addClass("level-"+ newLevel)
        swal personName, " is now a " + newTitle + " !" ,"success"




  $(".drag").droppable
    greedy: true
    tolerance: "touch"
    drop: (event, ui) ->
      ui.draggable.draggable "option", "revert", true
      return

  return
