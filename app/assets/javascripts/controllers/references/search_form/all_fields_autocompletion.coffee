$ ->
  references = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('references')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/references/autocomplete?reference_q=%QUERY'
      wildcard: '%QUERY'

  references.initialize()

  options = minLength: 2

  dataSet =
    name: 'references'
    limit: Infinity                    # bug in typeahead.js v0.11.1; limited on server-side anyway
    displayKey: 'search_query'
    source: references.ttAdapter()
    templates:
      empty:                           # TODO config partial keyword matching in solr
        '<div class="empty-message">' +
        'Unable to find any references that match the current query. ' +
        'Only whole words are considered matches.<br>' +
        '<small>Maybe try with a keyword? Examples: "author:bolton", "year:2003", "year:2003-2015".</small>' +
        '</div>'
      suggestion: (reference) ->
        '<p>' + reference.author + ' (' + reference.year + ')<br><small>' + reference.title + '</small></p>'
        # Note: `reference.author` is generated from `Reference.author_names_string`.

  $('input.typeahead-references-js').typeahead options, dataSet
