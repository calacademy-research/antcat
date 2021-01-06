const previewTaxonUrl = function(id) {
  return `/catalog/${id}/hover_preview.json`
}

const previewProtonymUrl = function(id) {
  return `/protonyms/${id}/hover_preview.json`
}

const previewReferenceUrl = function(id) {
  return `/references/${id}/hover_preview.json`
}

export {
  previewTaxonUrl,
  previewProtonymUrl,
  previewReferenceUrl,
}
