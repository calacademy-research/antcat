$ ->
  $(document).foundation()
  AntCat.setup_reference_keeys()

#_something seems to override this method when it's named
# enable - it doesn't get called
$.fn.undisable = ->
  @.removeClass('ui-state-disabled').removeAttr('disabled')

$.fn.disable = ->
  @.addClass('ui-state-disabled').attr('disabled', 'true')

# Defined on `AntCat` to make it possible to re-trigger after generating
# markown preview of references (in `preview_markdown.coffee`).
# TODO maybe rename. Working name: `AntCat.make_reference_keeys_expandable`.
AntCat.setup_reference_keeys = ->
  $('.reference_keey, .reference_keey_expansion_text').on 'click', ->
    $(@).closest('.reference_keey_and_expansion')
      .find('.reference_keey, .reference_keey_expansion')
      .toggle()
    false

# find just the topmost elements that match - don't drill down into them
$.fn.find_topmost = (selector) ->
  all_elements = @find(selector)
  all_elements.filter -> not all_elements.is $(@).parents()

$.fn.select = -> @.addClass 'ui-selecting'

AntCat.deselect = -> $('.ui-selecting').removeClass('ui-selecting')
