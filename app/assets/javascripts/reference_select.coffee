$ ->
  REFERENCE_SELECT_SELECTOR = 'select[data-reference-select]'
  $(REFERENCE_SELECT_SELECTOR).each -> $(this).referenceSelectify()

$.fn.referenceSelectify = ->
  selectElement = this
  $(selectElement).select2
    theme: 'bootstrap'
    templateResult: (item) ->
      return if item.loading
      "<small>##{item.id}</small> #{item.author} (#{item.year}) <small>#{item.title}</small>"
    templateSelection: (item) ->
      return '(none)' unless item.id
      author = $(selectElement).data 'author'
      year = $(selectElement).data 'year'
      title = $(selectElement).data 'title'
      "<small>##{item.id}</small> #{item.author || author} (#{item.year || year}) <small>#{item.title || title}</small>"
    escapeMarkup: (m) -> m
    minimumInputLength: 1
    placeholder: '???'
    allowClear: true
    ajax:
      url: '/references/autocomplete'
      dataType: 'json'
      data: (params) -> { qq: params.term }
      processResults: (data) -> { results: data }
