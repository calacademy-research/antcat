# A  "taxtable" is a database plaintext column which contains "taxt" tags which resolves to a `Taxon` or a `Reference`.

module Taxt
  # TODO: Decide what to do with this.
  TAXTABLES = [
    [Citation,         'citations',           'notes_taxt'],
    [ReferenceSection, 'reference_sections',  'references_taxt'],
    [ReferenceSection, 'reference_sections',  'subtitle_taxt'],
    [ReferenceSection, 'reference_sections',  'title_taxt'],
    [Taxon,            'taxa',                'headline_notes_taxt'],
    [Protonym,         'protonyms',           'primary_type_information_taxt'],
    [Protonym,         'protonyms',           'secondary_type_information_taxt'],
    [Protonym,         'protonyms',           'type_notes_taxt'],
    [Taxon,            'taxa',                'type_taxt'],
    [TaxonHistoryItem, 'taxon_history_items', 'taxt']
  ]
end
