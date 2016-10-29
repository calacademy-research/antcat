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
    displayKey: 'search_query'
    source: taxa.ttAdapter()
    templates:
      empty: '<div class="empty-message">No results</div>'
      suggestion: (taxon) -> '<p>' + taxon.name + '<br><small>' + taxon.authorship + '</small></p>'

  $('input.typeahead-taxa-js-hook').typeahead options, dataSet

  # Press Enter to submit header search box form with selected suggestion.
  $('#desktop-lower-menu').on 'keyup', (e) ->
    if e.which == 13
      e.preventDefault()
      selectables = $('input.typeahead-taxa-js-hook')
        .siblings(".tt-dropdown-menu").find(".tt-suggestion")
      if selectables.length > 0
        $(selectables[0]).trigger('click')
      else
        $("#header_search_button").trigger('click')
