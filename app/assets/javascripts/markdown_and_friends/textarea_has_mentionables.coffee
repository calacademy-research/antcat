# This adds autocompletion for users to textareas with `data-has-mentionables`.

$ ->
  setupMentionables()

setupMentionables = ->
  $("[data-has-mentionables]").atwho
    at: "@"
    searchKey: "search_key"
    insertTpl: "@user${id}"
    displayTpl: '<li><small>#${id}</small> ${name} <small>${email}</small></li>'
    callbacks:
      matcher: AntCat.allowSpacesWhileAutocompleting

      # `remoteFilter` is used to delay the query until an "@" is typed.
      remoteFilter: (query, callback) ->
        # Cached because mentionable users do not change very often.
        if AntCat._cachedMentionableUsers?
          return callback AntCat._cachedMentionableUsers

        MarkdownPreview.showSpinner this.$inputor
        $.getJSON "/users/mentionables.json", (data) =>
          data = data.map (user) ->
            user.search_key = "#{user.id} #{user.name} #{user.email}"
            user

          AntCat._cachedMentionableUsers = data
          MarkdownPreview.hideSpinner this.$inputor
          callback data
