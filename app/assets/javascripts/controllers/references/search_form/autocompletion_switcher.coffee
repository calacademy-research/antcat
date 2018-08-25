# We have two different search boxes that are conditionally shown/hidden,
# because each has their own autocompletion code.

$ ->
  setupReferenceAutocompletionSwitcher()

ALL_FIELDS_SEARCH_BOX = "#breadcrumbs .twitter-typeahead"
AUTHOR_SEARCH_BOX = "#author_q"

setupReferenceAutocompletionSwitcher = ->
  # Set initial visibility (in case a user has already made an author search).
  setSearchBoxesVisibility()

  # Enable autocompletion for the authors names search box.
  window.setupAdvancedAuthorAutocomplete $(AUTHOR_SEARCH_BOX)

  # Set change handler so that the correct search box is shown after selecting.
  $("#search_type").change -> setSearchBoxesVisibility()

# Shows/hides the correct inputs based on the search type select.
setSearchBoxesVisibility = ->
  search_type = $("#search_type option:selected").val()

  # "author" is the value of the option "Search by author(s)".
  if search_type is "author"
    $(ALL_FIELDS_SEARCH_BOX).hide()
    $(AUTHOR_SEARCH_BOX).show()
  else
    $(ALL_FIELDS_SEARCH_BOX).show()
    $(AUTHOR_SEARCH_BOX).hide()
