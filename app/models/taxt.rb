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

  # TODO: Move other variations of these to this file.
  # TODO: Name these per the tags, eg "TAX_TAG_REGEX".
  TAXON_TAG_REGEX = /(%taxon(?<id>\d+))|(\{tax (?<id>\d+)\})/
  TAXON_WITH_AUTHOR_CITATION_TAG_REGEX = /\{taxac (?<id>\d+)\}/
  TAX_OR_TAXAC_TAG_REGEX = /{(tax|taxac) (?<tax_id>[0-9]+})/
  REFERENCE_TAG_REGEX = /(%reference(?<id>\d+))|(\{ref (?<id>\d+)\})/

  ANTWEB_TAXON_TAG_REGEX = /{tax (\d+)}/
  ANTWEB_TAXON_WITH_AUTHOR_CITATION_TAG_REGEX = /{taxac (\d+)}/
  ANTWEB_REFERENCE_TAG_REGEX = /{ref (\d+)}/
end
