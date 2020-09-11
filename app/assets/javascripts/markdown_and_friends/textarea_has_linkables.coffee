# This adds some autocompletions to textareas with `data-has-linkables`.

$ ->
  setupLinkables()

reuseCallbacks = (url) ->
  matcher: AntCat.allowSpacesWhileAutocompleting
  # Added to make queries with parentheses work (subgenus names).
  # Based on https://github.com/ichord/At.js/blob/a627b5fcac22c35d52b7fb6d8a93181d2546f3c0/src/default.coffee#L125-L128
  highlighter: (li, query) ->
    return li if not query

    escapedQuery = AntCat.escapeRegExp query
    regexp = new RegExp(">\\s*([^\<]*?)(" + escapedQuery.replace("+","\\+") + ")([^\<]*)\\s*<", 'ig')
    li.replace regexp, (str, $1, $2, $3) -> '> ' + $1 + '<strong>' + $2 + '</strong>' + $3 + ' <'

  # Update recently used references if a reference is picked.
  beforeInsert: (value, _li) ->
    return value unless value.indexOf("{ref ") > -1
    $.ajax
      url: "/my/recently_used_references"
      type: 'POST'
      dataType: 'json'
      data: id: value.match(/\d+/)[0]
    value

  remoteFilter: (query, callback) ->
    MarkdownPreview.showSpinner this.$inputor
    $.getJSON url, q: query, (data) =>
      MarkdownPreview.hideSpinner this.$inputor
      callback data

  # Disable `sorter`. The default implementation removes good matches if the search
  # query isn't a substring of the field defined by `searchKey` (`name` by default).
  sorter: (query, items, searchKey) -> items

setupLinkables = =>
  referenceDisplayTpl =
    '<li><small>#${id}</small> ${author} (${year}) ${bolton_key} <small>${title}</small> ${full_pagination}</li>'

  $('[data-has-linkables]')
    .atwho
      at: '{t'
      limit: 10
      delay: 300
      maxLen: 50
      insertTpl: '{tax ${id}}:'
      displayTpl: '<li><small>#${id}</small> ${name_with_fossil} <small>${author_citation}</small></li>'
      callbacks: reuseCallbacks "/catalog/autocomplete.json"

    .atwho
      at: '{r'
      limit: 15
      delay: 300
      maxLen: 50
      insertTpl: '{ref ${id}}:'
      displayTpl: referenceDisplayTpl
      callbacks: reuseCallbacks "/references/linkable_autocomplete.json"

    .atwho
      at: '{p'
      limit: 15
      delay: 300
      maxLen: 50
      insertTpl: '{pro ${id}}:'
      displayTpl: '<li><small>#${id}</small> ${name_with_fossil} <small>${author_citation}</small></li>'
      callbacks: reuseCallbacks "/protonyms/autocomplete.json"

    .atwho
      at: '%w'
      limit: 10
      delay: 300
      insertTpl: '%wiki${id}'
      displayTpl: '<li><small>#${id}</small> ${title}</li>'
      callbacks: reuseCallbacks "/wiki_pages/autocomplete.json"

    .atwho
      at: '!!'
      limit: 15
      delay: 300
      maxLen: 50
      insertTpl: '{ref ${id}}:'
      displayTpl: referenceDisplayTpl
      callbacks: reuseCallbacks "/my/recently_used_references"
