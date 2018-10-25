# This adds some autocompletions to textareas with `data-has-linkables`.

$ ->
  AntCat.setupLinkables()

reuseCallbacks = (url) ->
  matcher: AntCat.allowSpacesWhileAutocompleting

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
    MDPreview.showSpinner this
    $.getJSON url, q: query, (data) =>
      MDPreview.hideSpinner this
      callback data

  # Disable `sorter`. The default implementation removes good matches if the search
  # query isn't a substring of the field defined by `searchKey` (`name` by default).
  sorter: (query, items, searchKey) -> items

AntCat.setupLinkables = =>
  referenceDisplayTpl =
    '<li><small>#${id}</small> ${author} (${year}) ${bolton_key} <small>${title}</small> ${full_pagination}</li>'

  $('[data-has-linkables]')
    .atwho
      at: '{t'
      limit: 10
      delay: 300
      maxLen: 50
      insertTpl: '{tax ${id}}:'
      displayTpl: '<li><small>#${id}</small> ${name_html} <small>${author_citation}</small></li>'
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
      at: '%i'
      limit: 10
      delay: 300
      insertTpl: '%issue${id}'
      displayTpl: '<li><small>#${id}</small> ${title} <small>${status}</small></li>'
      callbacks: reuseCallbacks "/issues/autocomplete.json"

    .atwho
      at: '%j'
      limit: 10
      delay: 300
      insertTpl: '%journal${id}'
      displayTpl: '<li><small>#${id}</small> ${name}</li>'
      callbacks: reuseCallbacks "/journals/linkable_autocomplete.json"

    .atwho
      at: '%f'
      limit: 10
      delay: 300
      insertTpl: '%feedback${id}'
      displayTpl: '<li><small>#${id}</small> ${date} <small>${status}</small></li>'
      callbacks: reuseCallbacks "/feedback/autocomplete.json"

    .atwho
      at: '!!'
      limit: 15
      delay: 300
      maxLen: 50
      insertTpl: '{ref ${id}}:'
      displayTpl: referenceDisplayTpl
      callbacks: reuseCallbacks "/my/recently_used_references"
