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
  TAX_TAG_REGEX = /(%taxon(?<id>\d+))|(\{tax (?<id>\d+)\})/
  TAXAC_TAG_REGEX = /\{taxac (?<id>\d+)\}/
  TAX_OR_TAXAC_TAG_REGEX = /{(tax|taxac) (?<tax_id>[0-9]+})/
  REF_TAG_REGEX = /(%reference(?<id>\d+))|(\{ref (?<id>\d+)\})/

  # Ignore percent format for AntWeb.
  # Ideally we would only have a single format, but it's not very important right now
  # since "taxt"s will be used less and less as we normalize content.
  ANTWEB_TAX_TAG_REGEX = /{tax (\d+)}/
  ANTWEB_TAXAC_TAG_REGEX = /{taxac (\d+)}/
  ANTWEB_REF_TAG_REGEX = /{ref (\d+)}/

  module_function

    def tax_or_taxac_tag_regex taxon
      "{(tax|taxac) #{taxon.id}}"
    end

    def ref_tag_regex reference
      "{ref #{reference.id}}"
    end
end
