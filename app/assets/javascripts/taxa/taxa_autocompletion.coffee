$ ->
  taxa = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('taxa')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/taxa/autocomplete?q=%QUERY'
      wildcard: '%QUERY'

  taxa.initialize()

  options =
    hint: true
    highlight: true
    minLength: 1

  dataSet =
    name: 'taxa'
    limit: Infinity # bug in typeahead.js v0.11.1; limited on server-side anyway
    displayKey: 'search_query'
    source: taxa.ttAdapter()
    templates:
      empty: '<div class="empty-message">No results</div>'
      suggestion: (taxon) -> '<p>' + taxon.name + '<br><small>' + taxon.authorship + '</small></p>'

  $('input.typeahead-taxa-js-hook').typeahead options, dataSet