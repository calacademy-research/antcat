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
                           'primary_type_information',
                           'secondary_type_information',
                           'type_notes'],
      Citation         => ['notes_taxt']
    }
    models.each_item_in_arrays_alias :each_field
    models
  end
end
