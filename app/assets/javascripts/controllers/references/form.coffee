$ ->
  setupReferenceTypeTabs()
  setupAutocompletion()

setupReferenceTypeTabs = ->
  $('.tabs').tabs() # Tabify.

  # Activates the relevant tab for this reference.
  selected_tab_index = $('#selected_tab_index').val()
  $('.tabs').tabs("option", "active", selected_tab_index)

  # Include reference type in the form before submitting
  $('form.edit_reference, form.new_reference').submit ->
    selectedTabText = $.trim($('.ui-tabs-active').text())
    selectedTab = switch selectedTabText
                    when 'Article' then 'ArticleReference'
                    when 'Book'    then 'BookReference'
                    when 'Nested'  then 'NestedReference'
                    when 'Other'   then 'UnknownReference'

    $('#reference_type').val(selectedTab)

setupAutocompletion = ->
  window.setupAuthorAutocomplete $('#reference_author_names_string')
  window.setupReferenceEditJournalAutocomplete $('#reference_journal_name')
  window.setupReferenceEditPublisherAutocomplete $('#reference_publisher_string')
