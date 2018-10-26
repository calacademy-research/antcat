window.AntCat = {}

$ ->
  $(document).foundation()
  AntCat.makeReferenceKeeysExpandable document

  enableInlineExpansions()

  # To make ".disabled" link be unclickable.
  $('body').on 'click', 'a.disabled', (event) -> event.preventDefault()

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
AntCat.makeReferenceKeeysExpandable = (element) ->
  $(element).find('.expandable-reference-key').on 'click', ->
    $(this).parent().find('.expandable-reference-content').toggle()
    $(this).toggle()
    false

  $(element).find('.expandable-reference-text').on 'click', ->
    $(this).parent().parent().find('.expandable-reference-key').toggle()
    $(this).parent().parent().find('.expandable-reference-content').toggle()
    false

# Used by `ApplicationHelper#inline_expandable`.
# TODO should be merge with `AntCat.makeReferenceKeeysExpandable`, but
# that requires a migration for invalidating reference caches.
enableInlineExpansions = ->
  $(".expandable").on "click", (event) ->
    $(this).find(".show-when-expanded, .hide-when-expanded").toggle()


$.fn.select = -> @.addClass 'ui-selecting'

AntCat.deselect = -> $('.ui-selecting').removeClass('ui-selecting')

# For at.js. Super comlicated way of saying "allow spaces and some other characters".
AntCat.allowSpacesWhileAutocompleting = (flag, subtext) ->
  # "c0-1ff" contains the range of weird diacrited letters starting at "À" and ending at "ǿ".
  # See http://qaz.wtf/u/show.cgi?show=c0-1ff&type=hex and https://unicode-table.com/en/#basic-latin
  regexp = new RegExp(flag + '([A-Za-z0-9_.,:\\u00c0-\\u01ff \+\-\]*)$|' + flag + '([^\\x00-\\xff]*)$', 'gi')

  match = regexp.exec(subtext)
  if match
    match[2] || match[1]
  else
    null

# Via https://stackoverflow.com/a/3966822
AntCat.getInputSelection = (el) ->
  start = 0
  end = 0
  normalizedValue = undefined
  range = undefined
  textInputRange = undefined
  len = undefined
  endRange = undefined
  if typeof el.selectionStart == 'number' and typeof el.selectionEnd == 'number'
    start = el.selectionStart
    end = el.selectionEnd
  else
    range = document.selection.createRange()
    if range and range.parentElement() == el
      len = el.value.length
      normalizedValue = el.value.replace(/\r\n/g, '\n')
      # Create a working TextRange that lives only in the input.
      textInputRange = el.createTextRange()
      textInputRange.moveToBookmark range.getBookmark()
      # Check if the start and end of the selection are at the very end
      # of the input, since moveStart/moveEnd doesn't return what we want
      # in those cases.
      endRange = el.createTextRange()
      endRange.collapse false
      if textInputRange.compareEndPoints('StartToEnd', endRange) > -1
        start = end = len
      else
        start = -textInputRange.moveStart('character', -len)
        start += normalizedValue.slice(0, start).split('\n').length - 1
        if textInputRange.compareEndPoints('EndToEnd', endRange) > -1
          end = len
        else
          end = -textInputRange.moveEnd('character', -len)
          end += normalizedValue.slice(0, end).split('\n').length - 1

  selectedValue = el.value.slice(start, end)
  selectedValue

# Toggle "show more" / "Show less".
$ ->
  options =
    maxLines: 1
    truncateString: "..."
    showText: """<span class="btn-normal btn-tiny">Show more</span>"""
    hideText: """<span class="btn-normal btn-tiny">Show less</span>"""
    hideClass: "anything-except-hide" # Because `.hide` conflics with jQuery.

    # HACK to make keys inside truncated elements to work after showing/hiding.
    animate: true
    animateOptions:
      complete: -> AntCat.makeReferenceKeeysExpandable $(".truncate")

  $(".truncate").truncate(options)

  # HACK to make keys inside truncated elements to work on page load.
  AntCat.makeReferenceKeeysExpandable $(".truncate")
