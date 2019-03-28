# TODO DRY various `Bloodhound`s.

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

  $('.locality-autocomplete-js-hook').typeahead options,
    name: 'localities'
    source: localities
    templates:
      empty: '<div class="empty-message">No results</div>'
      suggestion: (locality) -> "<p>#{locality}</p>"
