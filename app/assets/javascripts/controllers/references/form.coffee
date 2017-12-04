# TODO clear irrelevant attributes before save?

$ ->
  setupReferenceTypeTabs()
  setupAutocompletion()

setupReferenceTypeTabs = ->
  $('.tabs').tabs() # Tabify.

  # Activates the relevant tab for this reference.
  selected_tab = $('#selected_tab').val()
  $('.tabs').tabs("option", "active", selected_tab)

  # Include reference type in the form before submitting
  $('form.edit_reference, form.new_reference').submit ->
    selectedTab = $.trim($('.ui-tabs-active').text())
    $('#selected_tab').val(selectedTab)

setupAutocompletion = ->
  window.setupAuthorAutocomplete $('#reference_author_names_string')
  window.setupReferenceEditJournalAutocomplete $('#reference_journal_name')
  window.setupReferenceEditPublisherAutocomplete $('#reference_publisher_string')
