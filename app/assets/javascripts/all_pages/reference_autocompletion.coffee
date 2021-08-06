$ ->
  authors = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/authors/autocomplete?term=%QUERY&limit=5'
      wildcard: '%QUERY'

  authorsDataSet =
    name: 'authors'
    displayKey: 'label'
    source: authors.ttAdapter()
    limit: Infinity # NOTE: Bug in typeahead.js v0.11.1. See https://github.com/twitter/typeahead.js/issues/1232.
    templates:
      header: '<h5 class="autocompletion-header">Author results <small>(first 5)</small></h5>'
      empty: '<div class="empty-message">Unable to find any authors that match the current query.</div>'
      suggestion: (authorName) ->
        "<p>#{authorName.label}</p>"

  references = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/references/autocomplete?reference_q=%QUERY&include_search_query=yes'
      wildcard: '%QUERY'

  referencesDataSet =
    name: 'references'
    limit: Infinity # NOTE: Bug in typeahead.js v0.11.1; limited on server-side anyway.
    displayKey: 'search_query'
    source: references.ttAdapter()
    templates:
      header: '<h5 class="autocompletion-header">Reference results <small>(first 10)</small></h5>'
      empty:
        '<div class="empty-message">' +
        'Unable to find any references that match the current query.<br>' +
        '<small>Maybe try with a keyword? Examples: "author:bolton", "year:2003".</small>' +
        '</div>'
      suggestion: (reference) ->
        '<p>' + reference.author + ' (' + reference.year + ')<br><small>' + reference.title + '</small></p>'

  options =
    highlight: true
    minLength: 1

   $('input.typeahead-references-js').typeahead(options, authorsDataSet, referencesDataSet)
    .on 'typeahead:selected', (_event, suggestion) ->
      window.location.href = suggestion.url
