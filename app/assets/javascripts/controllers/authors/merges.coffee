$ ->
  setupAuthorAutocomplete()

setupAuthorAutocomplete = ->
  $("#author_to_merge_name").autocomplete
    autoFocus: true
    minLength: 3
    source: '/authors/autocomplete?with_ids=y'
    select: (event, ui) -> $("#author_to_merge_id").val ui.item.author_id
