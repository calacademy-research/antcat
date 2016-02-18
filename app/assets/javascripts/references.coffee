$ ->
  # Tabify
  $('.tabs').tabs()
  # Activates the relevant tab for this reference
  selected_tab = $('#selected_tab').val()
  $('.tabs').tabs("option", "active", selected_tab)

  # TODO clear irrelevant attributes before save

  # Autocompletion
  setupAuthorAutocomplete $('#reference_author_names_string')
  setupReferenceEditJournalAutocomplete $('#reference_journal_name')
  setupReferenceEditPublisherAutocomplete $('#reference_publisher_string')

  # Include reference type in the form before submitting
  $('form.edit_reference, form.new_reference').submit ->
    selectedTab = $.trim($('.ui-tabs-active').text())
    $('#selected_tab').val(selectedTab)