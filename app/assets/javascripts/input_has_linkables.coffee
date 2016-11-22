# This adds some autocompletions to textareas with `data-has-linkables`.
#
# The default `sorter` implementation is evil because is removes good matches
# for no good reason (imo). So, if the search query isn't a substring of
# the field defined by `searchKey` (`name` by default), the matches that we
# already know are good are *removed* -- not sorted last. This makes little sense
# for our remote data, and I do not know how to disable it.
#
# TODO DRY the loading spinner, delay, etc.

$ ->
  $('[data-has-linkables]')
    .atwho
      at: '%t'
      limit: 10
      delay: 300
      insertTpl: '%taxon${id}'
      displayTpl: '<li><small>#${id}</small> ${name} <small>${authorship}</small></li>'
      callbacks:
        matcher: AntCat.allowSpacesWhileAutocompleting

        remoteFilter: (query, callback) ->
          MDPreview.showSpinner()
          $.getJSON '/catalog/autocomplete.json', q: query, (data) ->
            MDPreview.hideSpinner()
            callback(data)

        # Disable `sorter`.
        sorter: (query, items, searchKey) -> items

    .atwho
      at: '%r'
      limit: 10
      delay: 300
      insertTpl: '%reference${id}'
      displayTpl: '<li><small>#${id}</small> ${author} (${year}) <small>${title}</small></li>'
      callbacks:
        matcher: AntCat.allowSpacesWhileAutocompleting

        remoteFilter: (query, callback) ->
          MDPreview.showSpinner()
          $.getJSON '/references/linkable_autocomplete.json', q: query, (data) ->
            MDPreview.hideSpinner()
            callback(data)

        # Disable `sorter`.
        sorter: (query, items, searchKey) -> items

    .atwho
      at: '%i'
      limit: 10
      delay: 300
      insertTpl: '%task${id}'
      displayTpl: '<li><small>#${id}</small> ${title} <small>${status}</small></li>'
      callbacks:
        matcher: AntCat.allowSpacesWhileAutocompleting

        remoteFilter: (query, callback) ->
          MDPreview.showSpinner()
          $.getJSON '/tasks/autocomplete.json', q: query, (data) ->
            MDPreview.hideSpinner()
            callback(data)

        # Disable `sorter`.
        sorter: (query, items, searchKey) -> items

    .atwho
      at: '%j'
      limit: 10
      delay: 300
      insertTpl: '%journal${id}'
      displayTpl: '<li><small>#${id}</small> ${name}</li>'
      callbacks:
        matcher: AntCat.allowSpacesWhileAutocompleting

        remoteFilter: (query, callback) ->
          MDPreview.showSpinner()
          $.getJSON '/journals/linkable_autocomplete.json', q: query, (data) ->
            MDPreview.hideSpinner()
            callback(data)

        # Disable `sorter`.
        sorter: (query, items, searchKey) -> items

    .atwho
      at: '%f'
      limit: 10
      delay: 300
      insertTpl: '%feedback${id}'
      displayTpl: '<li><small>#${id}</small> ${date} <small>${status}</small></li>'
      callbacks:
        matcher: AntCat.allowSpacesWhileAutocompleting

        remoteFilter: (query, callback) ->
          MDPreview.showSpinner()
          $.getJSON '/feedback/autocomplete.json', q: query, (data) ->
            MDPreview.hideSpinner()
            callback(data)

        # Disable `sorter`.
        sorter: (query, items, searchKey) -> items
