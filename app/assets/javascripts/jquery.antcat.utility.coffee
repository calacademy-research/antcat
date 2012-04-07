$.fn.enable = ->
  return $(this).each -> $(this).addClass 'ui-state-enable'

$.fn.disable = ->
  return $(this).each -> $(this).addClass 'ui-state-disable'
