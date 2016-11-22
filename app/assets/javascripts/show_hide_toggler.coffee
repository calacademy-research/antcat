# jQuery function for toggling show/hide from another element.
#
# On the element that should be toggleable:
#   Set `data-show-hide-toggable-id="example"`
#
# On the element that should work as a toggler:
#   Set `data-show-hide-toggler-for="example"`

$ ->
  hideToggleables()
  $('*[data-show-hide-toggler-for]').makeShowHideToggler()

# This is for the element that toggles the other element.
$.fn.makeShowHideToggler = ->
  toggleable_id = @data "show-hide-toggler-for"
  element_to_toggle = $("*[data-show-hide-toggable-id='#{toggleable_id}']")

  @click (event) ->
    event.preventDefault()
    element_to_toggle.slideToggle("slow")

# Start out with all toggleables hidden.
hideToggleables = -> $("*[data-show-hide-toggable-id]").hide()
