# For toggling show/hide from another element.
#
# On the element that should be toggleable:
#   Set `data-show-hide-toggable-id="example"`
#
# On the element that should work as a toggler:
#   Set `data-show-hide-toggler-for="example"`
#
# This is more revealing of intent than selecting on the elements'
# classes/ids, and we also avoid many of the headaches related to that.

$ ->
  hideToggleables()
  $('*[data-show-hide-toggler-for]').each -> makeShowHideToggler $(this)

# For the element (the toggler) that toggles
# the other element (the toggleable).
makeShowHideToggler = (toggler) ->
  toggleableId = toggler.data "show-hide-toggler-for"
  toggleable = $("*[data-show-hide-toggable-id='#{toggleableId}']")

  toggler.click (event) ->
    event.preventDefault()
    toggleable.slideToggle()

# Start out with all toggleables hidden.
hideToggleables = -> $("*[data-show-hide-toggable-id]").hide()
