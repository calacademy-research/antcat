# frozen_string_literal: true

module Taxt
  # A "taxtable" is a plaintext database column which may contain "taxt" tags,
  # which render with special markup and/or resolves to a `Taxon`, `Reference`, or `Protonym` record.
  TAXTABLES = [
    [ReferenceSection, 'reference_sections',  'references_taxt'],
    [ReferenceSection, 'reference_sections',  'subtitle_taxt'],
    [ReferenceSection, 'reference_sections',  'title_taxt'],
    [Protonym,         'protonyms',           'etymology_taxt'],
    [Protonym,         'protonyms',           'primary_type_information_taxt'],
    [Protonym,         'protonyms',           'secondary_type_information_taxt'],
    [Protonym,         'protonyms',           'type_notes_taxt'],
    [Protonym,         'protonyms',           'notes_taxt'],
    [HistoryItem,      'history_items',       'taxt']
  ]

  TAXON_TAGS = [
    TAX_TAG = 'tax',
    TAXAC_TAG = 'taxac' # Taxon with Author Citation.
  ]
  TAXON_TAG_REGEX = /\{(?<tag>#{TAXON_TAGS.join('|')}) (?<taxon_id>[0-9]+)\}/
  TAX_TAG_REGEX = /\{#{TAX_TAG} (?<taxon_id>\d+)\}/
  TAXAC_TAG_REGEX = /\{#{TAXAC_TAG} (?<taxon_id>\d+)\}/

  PROTONYM_TAGS = [
    PRO_TAG = 'pro',
    PROAC_TAG = 'proac', # Protonym with Author Citation.
    PROTT_TAG = 'prott', # Terminal Taxon of Protonym.
    PROTTAC_TAG = 'prottac' # Terminal Taxon of Protonym, with Author Citation.
  ]
  PROTONYM_TAG_REGEX = /\{(?<tag>#{PROTONYM_TAGS.join('|')}) (?<protonym_id>[0-9]+)\}/
  PRO_TAG_REGEX = /\{#{PRO_TAG} (?<protonym_id>\d+)\}/
  PROAC_TAG_REGEX = /\{#{PROAC_TAG} (?<protonym_id>\d+)\}/
  PROTT_TAG_REGEX = /\{#{PROTT_TAG} (?<protonym_id>\d+)\}/
  PROTTAC_TAG_REGEX = /\{#{PROTTAC_TAG} (?<protonym_id>\d+)\}/

  REFERENCE_TAGS = [
    REF_TAG = 'ref'
  ]
  REFERENCE_TAG_REGEX = /\{(?<tag>#{REFERENCE_TAGS.join('|')}) (?<reference_id>\d+)\}/
  REF_TAG_REGEX = REFERENCE_TAG_REGEX

  MISSING_TAG = 'missing'
  MISSING_TAG_REGEX = /\{#{MISSING_TAG}[0-9]? (?<hardcoded_name>.*?)\}/
  UNMISSING_TAG = 'unmissing'
  UNMISSING_TAG_REGEX = /\{#{UNMISSING_TAG} (?<hardcoded_name>.*?)\}/
  MISSING_OR_UNMISSING_TAG_REGEX = /\{(?:#{MISSING_TAG}|#{UNMISSING_TAG})(?:[0-9])? (?<hardcoded_name>.*?)\}/
  MISSPELLING_TAG = 'misspelling'
  MISSPELLING_TAG_REGEX = /\{#{MISSPELLING_TAG} (?<hardcoded_name>.*?)\}/

  HIDDENNOTE_TAG = 'hiddennote' # Hidden editor notes, logged-in only.
  HIDDENNOTE_TAG_REGEX = /\{#{HIDDENNOTE_TAG} (?<note_content>.*?)\}/

  PARSERTAG_TAG = 'parsertag' # Hidden parser tag notes, logged-in only.
  PARSERTAG_TAG_REGEX = /\{#{PARSERTAG_TAG}(?<optional_content>.*?)\}/

  module RecordToTagRegex
    module_function

    def taxon taxon
      "{(#{TAXON_TAGS.join('|')}) #{taxon.id}}"
    end

    def protonym protonym
      "{(#{PROTONYM_TAGS.join('|')}) #{protonym.id}}"
    end

    def reference reference
      "{#{REFERENCE_TAGS.join('|')} #{reference.id}}"
    end
  end

  module RecordToTag
    def taxon_to_tax_tag taxon
      "{#{TAX_TAG} #{taxon.id}}"
    end

    def protonym_to_pro_tag protonym
      "{#{PRO_TAG} #{protonym.id}}"
    end

    def reference_to_ref_tag reference
      "{#{REF_TAG} #{reference.id}}"
    end
  end

  module_function

  extend RecordToTag # Included as a shorthand.

  # TODO: DRY w.r.t. `RecordToTag::reference_to_ref_tag`.
  def to_ref_tag reference_or_id
    reference_id = reference_or_id.is_a?(Reference) ? reference_or_id.id : reference_or_id
    "{#{REF_TAG} #{reference_id}}"
  end

  # Taxon-related tags.
  def extract_tags_and_ids_from_taxon_tags taxt
    taxt.scan(TAXON_TAG_REGEX).map { |(tag, taxon_id)| [tag, taxon_id.to_i] }
  end

  def extract_ids_from_taxon_tags taxt
    extract_tags_and_ids_from_taxon_tags(taxt).map(&:last)
  end

  def extract_ids_from_tax_tags taxt
    taxt.scan(TAX_TAG_REGEX).flatten.compact.map(&:to_i)
  end

  # Protonym-related tags.
  def extract_tags_and_ids_from_protonym_tags taxt
    taxt.scan(PROTONYM_TAG_REGEX).map { |(tag, protonym_id)| [tag, protonym_id.to_i] }
  end

  def extract_ids_from_protonym_tags taxt
    extract_tags_and_ids_from_protonym_tags(taxt).map(&:last)
  end

  # Reference-related tags.
  def extract_ids_from_reference_tags taxt
    taxt.scan(REFERENCE_TAG_REGEX).map(&:last).flatten.compact.map(&:to_i)
  end
end
