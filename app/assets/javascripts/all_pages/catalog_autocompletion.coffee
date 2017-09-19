$ ->
  taxa = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('taxa')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/catalog/autocomplete?q=%QUERY'
      wildcard: '%QUERY'

  taxa.initialize()

  options =
    hint: true
    highlight: true
    minLength: 1

  dataSet =
    name: 'taxa'
    limit: Infinity # bug in typeahead.js v0.11.1; limited on server-side anyway
    displayKey: 'name'
    source: taxa.ttAdapter()
    templates:
      empty: '<div class="empty-message">No results</div>'
      suggestion: (taxon) ->
        "<p>#{taxon.name_html}<br><small>#{taxon.author_citation}</small></p>"

  $('input.typeahead-taxa-js-hook').typeahead(options, dataSet)
    .on 'typeahead:selected', (e) ->
      # To make clicking on a suggestion or pressing Enter submit the form.
      $("#header_search_button").addClass "disabled"
      e.target.form.submit()
