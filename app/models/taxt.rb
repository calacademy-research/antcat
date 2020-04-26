# frozen_string_literal: true

# A  "taxtable" is a database plaintext column which contains "taxt" tags which resolves to a `Taxon` or a `Reference`.

module Taxt
  # TODO: Required for as long as we have denormalized taxt items.
  TAXA_FIELDS_REFERENCING_TAXA = %i[
    subfamily_id
    tribe_id
    genus_id
    subgenus_id
    species_id
    subspecies_id

    current_valid_taxon_id
    homonym_replaced_by_id
    type_taxon_id
  ]

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

  TAX_TAG_REGEX = /(%taxon(?<id>\d+))|(\{tax (?<id>\d+)\})/
  TAXAC_TAG_REGEX = /\{taxac (?<id>\d+)\}/
  TAX_OR_TAXAC_TAG_REGEX = /{(tax|taxac) (?<tax_id>[0-9]+})/
  REF_TAG_REGEX = /(%reference(?<id>\d+))|(\{ref (?<id>\d+)\})/

  MISSING_OR_UNMISSING_TAX_TAG = /\{(missing|unmissing)_tax (?<hardcoded_name>.*?)\}/
  MISSING_TAX_TAG_REGEX = /\{missing_tax (?<hardcoded_name>.*?)\}/
  UNMISSING_TAX_TAG_REGEX = /\{unmissing_tax (?<hardcoded_name>.*?)\}/

  module_function

  def tax_or_taxac_tag_regex taxon
    "{(tax|taxac) #{taxon.id}}"
  end

  def ref_tag_regex reference
    "{ref #{reference.id}}"
  end
end
