# frozen_string_literal: true

# A "taxtable" is a database plaintext column which contains "taxt" tags which resolves to a `Taxon` or a `Reference`.

module Taxt
  TAXTABLES = [
    [ReferenceSection, 'reference_sections',  'references_taxt'],
    [ReferenceSection, 'reference_sections',  'subtitle_taxt'],
    [ReferenceSection, 'reference_sections',  'title_taxt'],
    [Protonym,         'protonyms',           'primary_type_information_taxt'],
    [Protonym,         'protonyms',           'secondary_type_information_taxt'],
    [Protonym,         'protonyms',           'type_notes_taxt'],
    [Protonym,         'protonyms',           'notes_taxt'],
    [TaxonHistoryItem, 'taxon_history_items', 'taxt']
  ]

  TAX_TAG_REGEX = /\{tax (?<id>\d+)\}/
  TAXAC_TAG_REGEX = /\{taxac (?<id>\d+)\}/
  TAX_OR_TAXAC_TAG_REGEX = /\{(?:tax|taxac) (?<tax_id>[0-9]+\})/

  PRO_TAG_REGEX = /\{pro (?<id>\d+)\}/

  REF_TAG_REGEX = /\{ref (?<id>\d+)\}/

  MISSING_OR_UNMISSING_TAG = /\{(?:missing|unmissing) (?<hardcoded_name>.*?)\}/
  MISSING_TAG_REGEX = /\{missing (?<hardcoded_name>.*?)\}/
  MISSING_TAG_START = "{missing "
  UNMISSING_TAG_REGEX = /\{unmissing (?<hardcoded_name>.*?)\}/
  MISSPELLING_TAG_REGEX = /\{misspelling (?<hardcoded_name>.*?)\}/

  module_function

  def tax_or_taxac_tag_regex taxon
    "{(tax|taxac) #{taxon.id}}"
  end

  def pro_tag_regex protonym
    "{pro #{protonym.id}}"
  end

  def ref_tag_regex reference
    "{ref #{reference.id}}"
  end
end
