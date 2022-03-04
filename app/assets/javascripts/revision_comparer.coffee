# This is for hiding unavailable radio options in the revision history table.
#
# See https://en.wikipedia.org/w/index.php?title=Example&action=history
# for how it is supposed to work.

$ ->
  setInitialState()
  setChangeCallback()

ALL_RADIOS   = "input[type=radio]"
DIFF_WITH_ID = "input[name=diff_with_id]" # Left options.
SELECTED_ID  = "input[name=selected_id]" # Right options.

setInitialState = ->
  unless $("#{SELECTED_ID}:checked").length > 0
    hideUnavailableRadios()
    $("#{SELECTED_ID}:visible").first().prop("checked", true)

  unless $("#{DIFF_WITH_ID}:checked").length > 0
    hideUnavailableRadios()
    $("#{DIFF_WITH_ID}:visible").first().prop("checked", true)

  hideUnavailableRadios()

setChangeCallback = -> $(ALL_RADIOS).change hideUnavailableRadios

hideUnavailableRadios = ->
  $(ALL_RADIOS).show()

  unavailable_DIFF_WITH_ID_radios().hide()
  unavailable_SELECTED_ID_radios().hide()

unavailable_DIFF_WITH_ID_radios = ->
  SELECTED_ID_index = parseInt($("#{SELECTED_ID}:checked").data('radio-button-index'))
  $ jQuery.grep $(DIFF_WITH_ID), (v) ->
    $(v).data('radio-button-index') <= SELECTED_ID_index

unavailable_SELECTED_ID_radios = ->
  DIFF_WITH_ID_index = parseInt($("#{DIFF_WITH_ID}:checked").data('radio-button-index'))

  $ jQuery.grep $(SELECTED_ID), (v) ->
    $(v).data('radio-button-index') >= DIFF_WITH_ID_index
