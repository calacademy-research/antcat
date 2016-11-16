# Last relics of a former empire.
#
# Code for parsing taxts into HTML/text have been moved to `TaxtPresenter`:
#   `Taxt.to_string`           --> `TaxtPresenter#to_html`
#   `Taxt.to_display_sentence` --> `TaxtPresenter#to_text`
#
# Code related to editing in the JS taxt editor have been moved to `TaxtConverter`:
#   `Taxt.to_editable`   --> `TaxtConverter.to_editor_format`
#   `Taxt.from_editable` --> `TaxtConverter.from_editor_format`

module Taxt
  TAXT_FIELDS = [
    [Taxon, [:type_taxt, :headline_notes_taxt, :genus_species_header_notes_taxt]],
    [Citation, [:notes_taxt]],
    [ReferenceSection, [:title_taxt, :subtitle_taxt, :references_taxt]],
    [TaxonHistoryItem, [:taxt]]
  ]
end
