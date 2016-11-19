# This adds some autocompletions to textareas with `data-has-linkables`.
#
# The default `sorter` implementation is evil because is removes good matches
# for no good reason (imo). So, if the search query isn't a substring of
# the field defined by `searchKey` (`name` by default), the matches that we
# already know are good are *removed* -- not sorted last. This makes little sense
# for our remote data, and I do not know how to disable it.

$ ->
  $('[data-has-linkables]')
    .atwho
      at: '%t'
      limit: 10
      insertTpl: '%taxon${id}'
      displayTpl: '<li><small>#${id}</small> ${name} <small>${authorship}</small></li>'
      callbacks:
        matcher: AntCat.allowSpacesWhileAutocompleting

        remoteFilter: (query, callback) ->
          $.getJSON '/catalog/autocomplete.json', q: query, (data) ->
            callback(data)

        # Disabled because evil.
        sorter: (query, items, searchKey) -> items

    .atwho
      at: '%r'
      limit: 10
      insertTpl: '%reference${id}'
      displayTpl: '<li><small>#${id}</small> ${author} (${year}) <small>${title}</small></li>'
      callbacks:
        matcher: AntCat.allowSpacesWhileAutocompleting

        remoteFilter: (query, callback) ->
          $.getJSON '/references/linkable_autocomplete.json', q: query, (data) ->
            callback(data)

        # Disabled because evil.
        sorter: (query, items, searchKey) -> items

