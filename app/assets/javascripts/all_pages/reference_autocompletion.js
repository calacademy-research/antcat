$(() => {
  const authors = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: '/authors/autocomplete.json?term=%QUERY&limit=5',
      wildcard: '%QUERY',
    },
  })

  const authorsDataSet = {
    name: 'authors',
    displayKey: 'label',
    source: authors.ttAdapter(),
    limit: Infinity,
    templates: {
      header: '<h5 class="text-base font-bold">Author results <small>(first 5)</small></h5>',
      empty: '<div class="text-sm p-2">Unable to find any authors that match the current query</div>',
      suggestion: (authorName) => `<p>${AntCat.escapeHtml(authorName.label)}</p>`,
    },
  }

  const references = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: '/references/autocomplete.json?reference_q=%QUERY&include_search_query=yes',
      wildcard: '%QUERY',
    },
  })

  const referencesDataSet = {
    name: 'references',
    limit: Infinity,
    displayKey: 'search_query',
    source: references.ttAdapter(),
    templates: {
      header: '<h5 class="text-base font-bold mt-4">Reference results <small>(first 10)</small></h5>',
      empty:
        '<div class="text-sm p-2">'
        + '<div class="mb-2">Unable to find any references that match the current query</div>'
        + '<div class="text-blue-800">Maybe try with a keyword? Examples: "author:bolton", "year:2003"</div>'
        + '</div>',
      suggestion: (reference) => {
        const author = AntCat.escapeHtml(reference.author)
        const year = AntCat.escapeHtml(reference.year)
        const title = AntCat.escapeHtml(reference.title)
        return `<p>${author} (${year})<br><small>${title}</small></p>`
      },
    },
  }

  const options = {
    highlight: true,
    minLength: 1,
  }

  const typeahead = $('input.typeahead-references-js').typeahead(options, authorsDataSet, referencesDataSet)
  typeahead.on('typeahead:selected', (_event, suggestion) => {
    window.location.href = suggestion.url
  })
})
