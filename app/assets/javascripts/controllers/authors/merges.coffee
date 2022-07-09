$ ->
  setupAuthorAutocomplete()

setupAuthorAutocomplete = ->
  $("#author_to_merge_name").autocomplete
    autoFocus: true
    minLength: 1
    source: '/authors/autocomplete.json'
    select: (_event, ui) -> $("#author_to_merge_id").val(ui.item.author_id)
