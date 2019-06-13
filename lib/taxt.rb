# Last relics of a former empire.

class Taxt
  TAXT_MODELS_AND_FIELDS = [
    [Citation,         'notes_taxt'],
    [ReferenceSection, 'references_taxt'],
    [ReferenceSection, 'subtitle_taxt'],
    [ReferenceSection, 'title_taxt'],
    [Taxon,            'headline_notes_taxt'],
    [Protonym,         'primary_type_information_taxt'],
    [Protonym,         'secondary_type_information_taxt'],
    [Protonym,         'type_notes_taxt'],
    [Taxon,            'type_taxt'],
    [TaxonHistoryItem, 'taxt']
  ]
end
