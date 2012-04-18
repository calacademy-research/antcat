#Something seems to overrie this method - it doesn't get called
#$.fn.enable = ->
  #$(this).removeClass 'ui-state-disabled'

$.fn.disable = ->
  $(this).addClass 'ui-state-disabled'
