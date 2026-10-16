// This adds autocompletion for users to textareas with `data-has-mentionables`.

// at.js templates use `${field}` placeholders in plain strings.
/* eslint-disable no-template-curly-in-string */
(() => {
  const setupMentionables = () => {
    $("[data-has-mentionables]").atwho({
      at: "@",
      searchKey: "search_key",
      insertTpl: "@user${id}",
      // Values are HTML-escaped in `remoteFilter` (at.js does not escape them).
      displayTpl: '<li><small>#${id}</small> ${name}</li>',
      callbacks: {
        matcher: AntCat.allowSpacesWhileAutocompleting,

        // `remoteFilter` is used to delay the query until an "@" is typed.
        remoteFilter: (query, callback) => {
          // Cached because mentionable users do not change very often.
          if (AntCat._cachedMentionableUsers != null) {
            callback(AntCat._cachedMentionableUsers)
            return
          }

          $.getJSON("/users/mentionables.json", (data) => {
            const users = data.map((user) => ({
              id: AntCat.escapeHtml(user.id),
              name: AntCat.escapeHtml(user.name),
              search_key: AntCat.escapeHtml(`${user.id} ${user.name}`),
            }))

            AntCat._cachedMentionableUsers = users
            callback(users)
          })
        },
      },
    })
  }

  $(() => {
    setupMentionables()
  })
})()
