// This adds some autocompletions to textareas with `data-has-linkables`.

// at.js templates use `${field}` placeholders in plain strings.
/* eslint-disable no-template-curly-in-string */
(() => {
  // at.js does not escape `${field}` values in `displayTpl`. Plain-text fields from the
  // server must be escaped before they reach at.js. Fields that are left out are HTML
  // built server-side from validated or escaped data (`name_with_fossil`, reference `title`).
  const escapeFields = (fields) => (data) => data.map((item) => {
    const escaped = { ...item }
    fields.forEach((field) => { escaped[field] = AntCat.escapeHtml(item[field]) })
    return escaped
  })

  const TAXON_TEXT_FIELDS = ['id', 'css_classes', 'author_citation']
  const REFERENCE_TEXT_FIELDS = ['id', 'author', 'year', 'bolton_key', 'full_pagination']
  const WIKI_PAGE_TEXT_FIELDS = ['id', 'title']

  const reuseCallbacks = (url, textFields) => ({
    matcher: AntCat.allowSpacesWhileAutocompleting,

    // Added to make queries with parentheses work (subgenus names).
    // Based on https://github.com/ichord/At.js/blob/a627b5fcac22c35d52b7fb6d8a93181d2546f3c0/src/default.coffee#L125-L128
    highlighter: (li, query) => {
      if (!query) return li

      const escapedQuery = AntCat.escapeRegExp(query)
      const regexp = new RegExp(`>\\s*([^<]*?)(${escapedQuery.replace("+", "\\+")})([^<]*)\\s*<`, 'ig')
      return li.replace(regexp, (str, $1, $2, $3) => `> ${$1}<strong>${$2}</strong>${$3} <`)
    },

    // Update recently used references if a reference is picked.
    beforeInsert: (value, _li) => {
      if (value.indexOf("{ref ") <= -1) return value

      $.ajax({
        url: "/my/recently_used_references",
        type: 'POST',
        dataType: 'json',
        data: { id: value.match(/\d+/)[0] },
      })
      return value
    },

    remoteFilter: (query, callback) => {
      $.getJSON(url, { q: query }, (data) => {
        callback(escapeFields(textFields)(data))
      })
    },

    // Disable `sorter`. The default implementation removes good matches if the search
    // query isn't a substring of the field defined by `searchKey` (`name` by default).
    sorter: (query, items, _searchKey) => items,
  })

  window.setupLinkables = () => {
    const referenceDisplayTpl = '<li><small>#${id}</small> ${author} (${year}) ${bolton_key} <small>${title}</small> ${full_pagination}</li>'

    const textareas = $('[data-has-linkables]')

    textareas.atwho({
      at: '{t',
      limit: 10,
      delay: 300,
      maxLen: 50,
      insertTpl: '{tax ${id}}:',
      displayTpl: [
        '<li>',
        "  <span class='text-sm text-gray-400'>#${id}</span>",
        "  <span class='${css_classes}'>${name_with_fossil}</span>",
        "  <span class='discreet-author-citation'>${author_citation}</span>",
        '</li>',
      ].join('\n'),
      callbacks: reuseCallbacks("/catalog/autocomplete.json", TAXON_TEXT_FIELDS),
    })

    textareas.atwho({
      at: '{r',
      limit: 15,
      delay: 300,
      maxLen: 50,
      insertTpl: '{ref ${id}}:',
      displayTpl: referenceDisplayTpl,
      callbacks: reuseCallbacks("/references/linkable_autocomplete.json", REFERENCE_TEXT_FIELDS),
    })

    textareas.atwho({
      at: '{p',
      limit: 15,
      delay: 300,
      maxLen: 50,
      insertTpl: '{pro ${id}}:',
      displayTpl: [
        '<li>',
        "  <span class='text-sm text-gray-400'>#${id}</span>",
        '  <span>${name_with_fossil}</span>',
        "  <span class='discreet-author-citation'>${author_citation}</span>",
        '</li>',
      ].join('\n'),
      callbacks: reuseCallbacks("/protonyms/autocomplete.json", TAXON_TEXT_FIELDS),
    })

    textareas.atwho({
      at: '%w',
      limit: 10,
      delay: 300,
      insertTpl: '%wiki${id}',
      displayTpl: '<li><small>#${id}</small> ${title}</li>',
      callbacks: reuseCallbacks("/wiki/autocomplete.json", WIKI_PAGE_TEXT_FIELDS),
    })

    textareas.atwho({
      at: '!!',
      limit: 15,
      delay: 300,
      maxLen: 50,
      insertTpl: '{ref ${id}}:',
      displayTpl: referenceDisplayTpl,
      callbacks: reuseCallbacks("/my/recently_used_references", REFERENCE_TEXT_FIELDS),
    })
  }

  $(() => {
    window.setupLinkables()

    document.body.setAttribute('data-test-atwho-loaded', "true") // HACK.
  })
})()
