$ ->
  TAXON_SELECT_SELECTOR = 'select[data-taxon-select]'
  $(TAXON_SELECT_SELECTOR).each -> $(this).taxonSelectify()

$.fn.taxonSelectify = ->
  selectElement = this
  return if $(selectElement).data('select2')

  $(selectElement).select2
    theme: 'bootstrap'
    templateResult: (item) ->
      return if item.loading

      """
        <span class='record-id'>##{item.id}</span>
        <span class='main-result #{item.css_classes}'>#{item.name_with_fossil}</span>
        <span class='discret-author-citation'>#{item.author_citation}</span>
      """
    templateSelection: (item) ->
      return '(none)' unless item.id

      nameWithFossil = $(selectElement).data 'name-with-fossil'
      authorCitation = $(selectElement).data 'author-citation'
      cssClasses = $(selectElement).data 'css-classes'

      """
        <span class='record-id'>##{item.id}</span>
        <span class='main-result #{item.css_classes || cssClasses}'>#{item.name_with_fossil || nameWithFossil}</span>
        <span class='discret-author-citation'>#{item.author_citation || authorCitation}</span>
      """
    escapeMarkup: (m) -> m
    minimumInputLength: 1
    placeholder: '???'
    allowClear: true
    ajax:
      url: '/catalog/autocomplete'
      dataType: 'json'
      data: (params) -> { qq: params.term, rank: $(selectElement).data('rank') }
      processResults: (data) -> { results: data }
