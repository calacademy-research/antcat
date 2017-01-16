# This adds autocompletion for users to textareas with `data-has-mentionables`.

$ ->
  setupMentionables()

setupMentionables = ->
  $("[data-has-mentionables]").atwho
    at: "@"
    searchKey: "mentionable_search_key"
    insertTpl: "@user${id}"
    displayTpl: '<li><small>#${id}</small> ${name} <small>${email}</small></li>'
    callbacks:
      matcher: AntCat.allowSpacesWhileAutocompleting

      # We use `remoteFilter` to avoid making the query before an "@" is typed.
      remoteFilter: (query, callback) ->
        # Mentionable users are always the same, so use cached if possible.
        if AntCat.cached_mentionables?
          return callback AntCat.cached_mentionables

        MDPreview.showSpinner this
        $.getJSON "/users/mentionables.json", (data) =>
          AntCat.cached_mentionables = data
          MDPreview.hideSpinner this
          callback data
