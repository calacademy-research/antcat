$ ->
  ADVANCED_SEARCH_FORM_LINK = '<a id="advanced-search-form-link" href="/catalog/search">Show advanced search form...</a>'

  taxa = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/catalog/autocomplete.json?q=%QUERY'
      wildcard: '%QUERY'

  taxaDataSet =
    name: 'taxa'
    limit: Infinity # NOTE: Bug in typeahead.js v0.11.1; limited on server-side anyway.
    displayKey: 'plaintext_name'
    source: taxa.ttAdapter()
    templates:
      header: """
        <h5 class="autocompletion-header">
          Taxon results <small>(first 10)</small>
        </h5>
        """
      empty: """
        <div class="empty-message">
          Unable to find any taxa that match the current query.<br>#{ADVANCED_SEARCH_FORM_LINK}
        </div>
        """
      suggestion: (taxon) ->
        "<p><span class='#{taxon.css_classes}'>#{taxon.name_with_fossil}</span> <small>#{taxon.author_citation}</small></p>"

  protonyms = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/protonyms/autocomplete.json?qq=%QUERY'
      wildcard: '%QUERY'

  protonymsDataSet =
    name: 'protonyms'
    limit: Infinity # NOTE: Bug in typeahead.js v0.11.1; limited on server-side anyway.
    displayKey: 'plaintext_name'
    source: protonyms.ttAdapter()
    templates:
      header: '<h5 class="autocompletion-header">Protonym results <small>(first 10)</small></h5>'
      empty: '<div class="empty-message">Unable to find any protonyms that match the current query.</div>'
      suggestion: (protonym) ->
        "<p>#{protonym.name_with_fossil} <small>#{protonym.author_citation}</small></p>"

  options =
    hint: true
    highlight: true
    minLength: 1

  $('input.typeahead-taxa-js-hook').typeahead(options, taxaDataSet, protonymsDataSet)
    .on 'typeahead:selected', (_event, suggestion) ->
      window.location.href = suggestion.url
