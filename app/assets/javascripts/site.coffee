$ ->
  $(document).foundation()
  setup_login()
  setup_reference_keys()
  $('input[type=text]:visible:first').focus()

setup_login = ->
  $('#login .form').hide()
  $('#login a.link').click -> $('#login div').toggle()

#_something seems to override this method when it's named
# enable - it doesn't get called
$.fn.undisable = ->
  @.removeClass('ui-state-disabled').removeAttr('disabled')

$.fn.disable = ->
  @.addClass('ui-state-disabled').attr('disabled', 'true')

setup_reference_keys = ->
  $('.reference_key, .reference_key_expansion_text').on 'click', ->
    $(@).closest('.reference_key_and_expansion')
      .find('.reference_key, .reference_key_expansion')
      .toggle()
    false

# find just the topmost elements that match - don't drill down into them
$.fn.find_topmost = (selector) ->
  all_elements = @find(selector)
  all_elements.filter -> not all_elements.is $(@).parents()

$.fn.select = -> @.addClass 'ui-selecting'

AntCat.deselect = -> $('.ui-selecting').removeClass('ui-selecting')
