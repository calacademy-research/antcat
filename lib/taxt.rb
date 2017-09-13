# Last relics of a former empire.
#
# Code for parsing taxts into HTML/text have been moved to `TaxtPresenter`:
#   `Taxt.to_string`           --> `TaxtPresenter#to_html`
#   `Taxt.to_display_sentence` --> `TaxtPresenter#to_text`
#
# Code related to editing in the JS taxt editor have been moved to `TaxtConverter`:
#   `Taxt.to_editable`   --> `TaxtConverter.to_editor_format`
#   `Taxt.from_editable` --> `TaxtConverter.from_editor_format`

class Taxt
  # [Old] constant for finding "taxt" fields.
  TAXT_FIELDS = [
    [Taxon, [:type_taxt, :headline_notes_taxt, :genus_species_header_notes_taxt]],
    [Citation, [:notes_taxt]],
    [ReferenceSection, [:title_taxt, :subtitle_taxt, :references_taxt]],
    [TaxonHistoryItem, [:taxt]]
  ]

  # [Newer] method for finding "taxt" fields.
  def self.models_with_taxts
    # Model / field(s).
    models = {
      ReferenceSection => ['references_taxt',
                           'title_taxt',
                           'subtitle_taxt'],
      TaxonHistoryItem => ['taxt'],
      Taxon            => ['headline_notes_taxt',
                           'type_taxt',
                           'genus_species_header_notes_taxt'],
      Citation         => ['notes_taxt']
    }
    models.each_item_in_arrays_alias :each_field
    models
  end
end
