$ ->
  setupReferenceTypeTabs()
  setupAutocompletion()

setupReferenceTypeTabs = ->
  referenceType = ->
    openTabId = $('#reference-tabs').find('.is-active a').attr('id')
    switch openTabId
      when 'tabs-article-label' then 'ArticleReference'
      when 'tabs-book-label'    then 'BookReference'
      when 'tabs-nested-label'  then 'NestedReference'
      when 'tabs-unknown-label' then 'UnknownReference'

  # Include reference type in the form before submitting.
  $('form.edit_reference, form.new_reference').submit -> $('#reference_type').val(referenceType)

setupJournalAutocompletion = ->
  $('#reference_journal_name').autocomplete
    autoFocus: true
    source: '/journals/autocomplete'
    minLength: 3

setupPublisherAutocompletion = ->
  $('#reference_publisher_string').autocomplete
    autoFocus: true
    source: '/publishers/autocomplete'
    minLength: 3

setupAutocompletion = ->
  window.setupAdvancedAuthorAutocomplete $('#reference_author_names_string')
  setupJournalAutocompletion()
  setupPublisherAutocompletion()
