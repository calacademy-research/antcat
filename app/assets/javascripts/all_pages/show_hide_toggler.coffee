# For toggling show/hide from another element.
#
# On the element/button that should work as a toggler, set:
# ```
#   data-show-hide-toggler-for="example"
#
#   // like this:
#   =link_to "Show/hide", "#", data: { show_hide_toggler_for: "example" }, class: "btn-tiny btn-nodanger"
# ```
#
# On the element that should be toggleable, set:
# ```
#   `data-show-hide-toggable-id="example"
#
#   // like this:
#   %div{data: { show_hide_toggable_id: "example" }}
# ```

$ ->
  hideToggleables()
  $('*[data-show-hide-toggler-for]').each -> makeShowHideToggler $(this)

# For the element (the toggler) that toggles the other element (the toggleable).
makeShowHideToggler = (toggler) ->
  toggleableId = toggler.data "show-hide-toggler-for"
  toggleable = $("*[data-show-hide-toggable-id='#{toggleableId}']")

  toggler.click (event) ->
    event.preventDefault()
    toggleable.slideToggle()

# Start out with all toggleables hidden by default.
hideToggleables = ->
  $("*[data-show-hide-toggable-id]").not('.show-hide-toggable-starts-open').hide()
