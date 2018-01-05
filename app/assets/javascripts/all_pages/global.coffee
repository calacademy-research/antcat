$ ->
  $(document).foundation()
  AntCat.make_reference_keeys_expandable document

  enableInlineExpansions()

# Something seems to override this method when
# it's named "enable" - it doesn't get called.
$.fn.undisable = -> @.removeClass('ui-state-disabled').removeAttr('disabled')
$.fn.disable = -> @.addClass('ui-state-disabled').attr('disabled', 'true')

# Like above, but without jQuery UI classes.
$.fn.enableButton = -> @removeClass "disabled"
$.fn.disableButton = -> @addClass "disabled"

# Defined on `AntCat` to make it possible to re-trigger after generating
# markdown preview of references (in `preview_markdown.coffee`).
#
# The `element` qualifier is because each time we setup the
# same elements more than once, they alternate between working and not.
# Reference keys already in the DOM should not be touched after making
# references in the markdown preview expandable.
AntCat.make_reference_keeys_expandable = (element) ->
  $(element).find('.reference_keey, .reference_keey_expansion_text').on 'click', ->
    $(@).closest('.reference_keey_and_expansion')
      .find('.reference_keey, .reference_keey_expansion')
      .toggle()
    false

# Used by `ApplicationHelper#inline_expandable`.
# TODO should be merge with `AntCat.make_reference_keeys_expandable`, but
# that requires a migration for invalidating reference caches.
enableInlineExpansions = ->
  $(".expandable").on "click", (event) ->
    $(this).find(".show-when-expanded, .hide-when-expanded").toggle()

# find just the topmost elements that match - don't drill down into them
$.fn.find_topmost = (selector) ->
  all_elements = @find(selector)
  all_elements.filter -> not all_elements.is $(@).parents()

$.fn.select = -> @.addClass 'ui-selecting'

AntCat.deselect = -> $('.ui-selecting').removeClass('ui-selecting')

# For at.js. Super comlicated way of saying "allow spaces".
AntCat.allowSpacesWhileAutocompleting = (flag, subtext) ->
  regexp = new RegExp(flag + '([A-Za-z0-9_ \+\-\]*)$|' + flag + '([^\\x00-\\xff]*)$', 'gi')
  match = regexp.exec(subtext)
  if match
    match[2] || match[1]
  else
    null

# Toggle "show more" / "Show less".
$ ->
  SHOW_CHARS = 500
  MORE_TEXT = 'Show more'
  LESS_TEXT = 'Show less'

  $('.more').each ->
    content = $(this).html()
    if content.length > SHOW_CHARS
      beforeTruncation = content.substr(0, SHOW_CHARS)
      truncated = content.substr(SHOW_CHARS, content.length - SHOW_CHARS)

      html = """
        #{beforeTruncation}
        <span>... &nbsp;</span>
        <span class="more-content">
          <span>#{truncated}</span>
          &nbsp;&nbsp;
          <a href="" class="btn-normal btn-tiny more-link">#{MORE_TEXT}</a>
        </span>
      """
      $(this).html html

  $('.more-link').click (event) ->
    event.preventDefault()

    if $(this).hasClass('less')
      $(this).removeClass 'less'
      $(this).html MORE_TEXT
    else
      $(this).addClass 'less'
      $(this).html LESS_TEXT
    $(this).parent().prev().toggle()
    $(this).prev().toggle()
