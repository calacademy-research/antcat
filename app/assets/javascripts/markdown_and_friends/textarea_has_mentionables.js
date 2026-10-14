// This adds autocompletion for users to textareas with `data-has-mentionables`.

// at.js templates use `${field}` placeholders in plain strings.
/* eslint-disable no-template-curly-in-string */
(() => {
  const setupMentionables = () => {
    $("[data-has-mentionables]").atwho({
      at: "@",
      searchKey: "search_key",
      insertTpl: "@user${id}",
      displayTpl: '<li><small>#${id}</small> ${name} <small>${email}</small></li>',
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
            const users = data.map((user) => ({ ...user, search_key: `${user.id} ${user.name} ${user.email}` }))

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
