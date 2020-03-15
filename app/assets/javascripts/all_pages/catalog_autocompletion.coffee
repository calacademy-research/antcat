$ ->
  taxa = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/catalog/autocomplete?q=%QUERY'
      wildcard: '%QUERY'

  options =
    hint: true
    highlight: true
    minLength: 1

  dataSet =
    name: 'taxa'
    limit: Infinity # NOTE: Bug in typeahead.js v0.11.1; limited on server-side anyway.
    displayKey: 'name'
    source: taxa.ttAdapter()
    templates:
      empty: '<div class="empty-message">No results</div>'
      suggestion: (taxon) ->
        "<p>#{taxon.name_with_fossil}<br><small>#{taxon.author_citation}</small></p>"

  $('input.typeahead-taxa-js-hook').typeahead(options, dataSet)
    .on 'typeahead:selected', (e) ->
      # To make clicking on a suggestion or pressing Enter submit the form.
      e.target.form.submit()
