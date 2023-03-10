$ ->
  setupAuthorAutocomplete()

setupAuthorAutocomplete = ->
  $("#author_to_merge_name").autocomplete
    autoFocus: true
    minLength: 1
    source: '/authors/autocomplete.json'
    select: (_event, ui) -> $("#author_to_merge_id").get(0).value = ui.item.author_id
