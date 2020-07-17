window.AntCat = {}

TAXON_HOVER_PREVIEW_LINK_CSS_CLASS = 'taxon-hover-preview-link'
TAXON_HOVER_PREVIEW_CONTENT_CSS_CLASS = 'taxon-hover-preview-content'

$ ->
  $(document).foundation()

  enableInlineExpansions()
  AntCat.enableCatalogLinkHoverPreview(document)

  # To make ".disabled" link be unclickable.
  $('body').on 'click', 'a.disabled', (event) -> event.preventDefault()

# Something seems to override this method when
# it's named "enable" - it doesn't get called.
$.fn.undisable = -> @.removeClass('ui-state-disabled').removeAttr('disabled')
$.fn.disable = -> @.addClass('ui-state-disabled').attr('disabled', 'true')

# Like above, but without jQuery UI classes.
$.fn.enableButton = -> @removeClass "disabled"
$.fn.disableButton = -> @addClass "disabled"

AntCat.notifySuccess = (content, autoHide = true) -> $.notify content, className: "success", autoHide: autoHide
AntCat.notifyError = (content, autoHide = true) -> $.notify content, autoHide: autoHide

# Defined on `AntCat` to make it possible to re-trigger after generating
# markdown preview of references (in `preview_markdown.coffee`).
#
# The `element` qualifier is because each time we setup the
# same elements more than once, they alternate between working and not.
# Reference keys already in the DOM should not be touched after making
# references in the markdown preview expandable.
AntCat.makeReferenceKeysExpandable = (element) -> $(element).foundation()

# Used by `ApplicationHelper#inline_expandable`.
enableInlineExpansions = ->
  $(".expandable").on "click", (event) ->
    $(this).find(".show-when-expanded, .hide-when-expanded").toggle()

AntCat.hoverPreviewContent = (preview, previewCssClass) ->
  "<span class='color-coded-catalog-links #{previewCssClass}'>#{preview}</span>"

AntCat.enableCatalogLinkHoverPreview = (element) ->
  AntCat.hoverPreviewCache ||= {}

  $(element).find(".#{TAXON_HOVER_PREVIEW_LINK_CSS_CLASS}").on "mouseenter", (event) ->
    href = $(this).attr("href") # "/catalog/1234".
    cachedPreview = AntCat.hoverPreviewCache[href]

    if cachedPreview
      alreadyAppendedToThisElement = $(this).find(".#{TAXON_HOVER_PREVIEW_CONTENT_CSS_CLASS}").length
      return if alreadyAppendedToThisElement
      $(this).append AntCat.hoverPreviewContent(cachedPreview, TAXON_HOVER_PREVIEW_CONTENT_CSS_CLASS)
    else
      $.getJSON "#{href}/hover_preview.json", (data) =>
        preview = data.preview
        $(this).append AntCat.hoverPreviewContent(preview, TAXON_HOVER_PREVIEW_CONTENT_CSS_CLASS)
        AntCat.hoverPreviewCache[href] = preview

AntCat.escapeRegExp = (string) ->
  string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')

# For at.js. Super comlicated way of saying "allow spaces and some other characters".
# Based on https://github.com/ichord/At.js/blob/a627b5fcac22c35d52b7fb6d8a93181d2546f3c0/src/default.coffee#L46-L58
AntCat.allowSpacesWhileAutocompleting = (flag, subtext) ->
  # "c0-1ff" contains the range of weird diacrited letters starting at "À" and ending at "ǿ".
  # See http://qaz.wtf/u/show.cgi?show=c0-1ff&type=hex and https://unicode-table.com/en/#basic-latin
  regexp = new RegExp(flag + '([A-Za-z0-9()&_.,:\\u00c0-\\u01ff \+\-]*)$|' + flag + '([^\\x00-\\xff]*)$', 'gi')

  match = regexp.exec(subtext)
  if match
    match[2] || match[1]
  else
    null

# Via https://stackoverflow.com/a/3966822
AntCat.getInputSelection = (el, onlyStartPosition = false) ->
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

  return start if onlyStartPosition

  selectedValue = el.value.slice(start, end)
  selectedValue
