$ ->
  repositories = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    prefetch:
      url: '/type_specimen_repositories/autocompletion_data.json'

  repositories.clearPrefetchCache()
  repositories.initialize()

  options =
    hint: false
    highlight: true
    minLength: 1

  $('#taxon_type_specimen_repository').typeahead options,
    name: 'repositories'
    source: repositories
    templates:
      empty: '<div class="empty-message">No results</div>'
      suggestion: (repository) -> "<p>#{repository}</p>"
