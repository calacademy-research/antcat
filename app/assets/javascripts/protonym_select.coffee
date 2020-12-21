$ ->
  AntCat.protonymSelectifyAll()

AntCat.protonymSelectifyAll = ->
  PROTONYM_SELECT_SELECTOR = 'select[data-protonym-select]'
  $(PROTONYM_SELECT_SELECTOR).each -> $(this).protonymSelectify()

$.fn.protonymSelectify = ->
  selectElement = this
  return if $(selectElement).data('select2')

  $(selectElement).select2
    theme: 'bootstrap'
    templateResult: (item) ->
      return if item.loading

      """
        <span class='record-id'>##{item.id}</span>
        <span class='main-result'>#{item.name_with_fossil}</span>
        <span class='discret-author-citation'>#{item.author_citation}</span>
      """
    templateSelection: (item) ->
      return '(none)' unless item.id

      nameWithFossil = $(selectElement).data 'name-with-fossil'
      authorCitation = $(selectElement).data 'author-citation'

      """
        <span class='record-id'>##{item.id}</span>
        <span class='main-result'>#{item.name_with_fossil || nameWithFossil}</span>
        <span class='discret-author-citation'>#{item.author_citation || authorCitation}</span>
      """
    escapeMarkup: (m) -> m
    minimumInputLength: 1
    placeholder: '???'
    selectOnClose: true
    allowClear: true
    ajax:
      url: '/protonyms/autocomplete'
      dataType: 'json'
      data: (params) -> { qq: params.term }
      processResults: (data) -> { results: data }
