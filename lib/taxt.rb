# Last relics of a former empire.

class Taxt
  # Helper method for finding "taxt" fields.
  def self.models_with_taxts
    # Model / field(s).
    models = {
      ReferenceSection => ['references_taxt',
                           'title_taxt',
                           'subtitle_taxt'],
      TaxonHistoryItem => ['taxt'],
      Taxon            => ['headline_notes_taxt',
                           'type_taxt',
                           'genus_species_header_notes_taxt',
                           'published_type_information',
                           'additional_type_information',
                           'type_notes'],
      Citation         => ['notes_taxt']
    }
    models.each_item_in_arrays_alias :each_field
    models
  end
end
