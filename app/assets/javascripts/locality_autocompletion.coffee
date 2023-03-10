$ ->
  localities = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    prefetch:
      url: '/protonyms/localities/autocomplete.json'

  localities.clearPrefetchCache()

  options =
    hint: false
    highlight: true
    minLength: 1

  $("[data-use-locality-autocomplete]").typeahead options,
    name: 'localities'
    source: localities
    templates:
      empty: 'No results'
      suggestion: (locality) -> "<p>#{locality}</p>"
