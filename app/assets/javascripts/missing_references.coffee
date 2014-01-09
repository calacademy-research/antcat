$ ->
  $('.selectable').selectable
    selected: (event, ui) ->
      $(ui.selected).addClass('ui-selected').siblings().removeClass('ui-selected')

select_reference = (eventObject) ->
  console.log eventObject.target
  # eventObject.target can be the .citation element or the
  # .citation_text element - don't ask me why
  citation = text = $(eventObject.target).closest('.citation').find('.citation_text').text()
  @text = $(eventObject.target).closest('.citation').find('.citation_text').text()
