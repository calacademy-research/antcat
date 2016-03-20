$ ->
  # Linked taxa token field
  $('#task_taxa_tokens').tokenInput '/taxa/autocomplete',
    theme: 'facebook'
    minChars: 2
    tokenValue: "id"
    tokenFormatter: (item) ->
      '<li><p><a href="/catalog/' + item.id + '" target="_blank">' +
      item.name_html_cache + "</a></p></li>"
    resultsFormatter: (item) ->
      "<li><p>" + item.name_html_cache + "</p></li>"
    enableHTML: true
    prePopulate: $('#task_taxa_tokens').data('load')
