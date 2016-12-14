# This is for hiding/showing radio options in the revision
# history table, depending on which radios are selected.
#
# The left side of the split diff should always show the older
# revision; this is what makes some options "unavailable" this context.
# Go to https://en.wikipedia.org/w/index.php?title=Example&action=history
# to see how it is supposed to work and why it's useful.
#
# This is only tangentially tested in the test suite, but that's OK.

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

# All left-mosts radios ("DIFF_WITH_ID") above the checked "SELECTED_ID",
# ie those having a higher value, should be hidden.
unavailable_DIFF_WITH_ID_radios = ->
  # HACK because the `most_recent` revision doesn't have a version id.
  SELECTED_ID_value = parseInt $("#{SELECTED_ID}:checked").prop("value") || 99999999
  $ jQuery.grep $(DIFF_WITH_ID), (v) -> v.value >= SELECTED_ID_value

# All right-mosts radios ("SELECTED_ID") above the checked "DIFF_WITH_ID",
# ie those having a lower value, should be hidden.
unavailable_SELECTED_ID_radios = ->
  DIFF_WITH_ID_value = parseInt  $("#{DIFF_WITH_ID}:checked").prop("value")

  $ jQuery.grep $(SELECTED_ID), (v) ->
    return false if v.value == "" # Same HACK as below.
    v.value <= DIFF_WITH_ID_value
