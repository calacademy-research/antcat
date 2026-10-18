# frozen_string_literal: true

require 'strscan'

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
  # A hidden note runs to its matching closing brace, so tags inside it ("{hiddennote see {ref 1}: 2}")
  # are part of the note. A note without a matching closing brace runs to the end of the text.
  # Parsed with a linear scanner (`split_hidden_notes`) rather than a regex.
  HIDDENNOTE_OPENING = "{#{HIDDENNOTE_TAG} "
  HIDDENNOTE_OPENING_REGEX = /#{Regexp.escape(HIDDENNOTE_OPENING)}/
  BRACE_REGEX = /[{}]/

  module RecordToTagRegex
    module_function

    def taxon taxon
      "\\{(#{TAXON_TAGS.join('|')}) #{taxon.id}\\}"
    end

    def protonym protonym
      "\\{(#{PROTONYM_TAGS.join('|')}) #{protonym.id}\\}"
    end

    def reference reference
      "\\{#{REFERENCE_TAGS.join('|')} #{reference.id}\\}"
    end
  end

  module_function

  def tax taxon_id
    tag TAX_TAG, taxon_id
  end

  def taxac taxon_id
    tag TAXAC_TAG, taxon_id
  end

  def pro protonym_id
    tag PRO_TAG, protonym_id
  end

  def proac protonym_id
    tag PROAC_TAG, protonym_id
  end

  def prott protonym_id
    tag PROTT_TAG, protonym_id
  end

  def prottac protonym_id
    tag PROTTAC_TAG, protonym_id
  end

  def ref reference_id
    tag REF_TAG, reference_id
  end

  def tag tag, content
    "{#{tag} #{content}}"
  end

  # For output that visitors can see without signing in (the API, revision histories, rendered taxt).
  # Removes each hidden note (including any tags inside it) and the space before it.
  def remove_hidden_notes taxt
    return taxt unless hidden_notes?(taxt)

    split_hidden_notes(taxt).each_with_object(+'') do |(kind, text), output|
      if kind == :note
        output.delete_suffix!(' ')
      else
        output << text
      end
    end
  end

  # Replaces each hidden note with the block's result. The block gets the note's content and whether
  # the note was closed; an unclosed note is passed with the rest of the text as its content.
  def replace_hidden_notes taxt
    return taxt unless hidden_notes?(taxt)

    split_hidden_notes(taxt).each_with_object(+'') do |(kind, text, closed), output|
      output << (kind == :note ? yield(text, closed).to_s : text)
    end
  end

  def hidden_notes? taxt
    taxt.is_a?(String) && taxt.include?(HIDDENNOTE_OPENING)
  end

  # Splits taxt into `[:text, string]` and `[:note, content, closed]` parts. Braces inside a note are
  # balanced, so the note ends at the brace that closes the "{hiddennote" opening. Linear time.
  def split_hidden_notes taxt
    scanner = StringScanner.new(taxt)
    parts = []

    until scanner.eos?
      unless (before_and_opening = scanner.scan_until(HIDDENNOTE_OPENING_REGEX))
        parts << [:text, scanner.rest]
        break
      end

      parts << [:text, before_and_opening.delete_suffix(HIDDENNOTE_OPENING)]

      content = +''
      depth = 1
      while depth.positive? && (chunk = scanner.scan_until(BRACE_REGEX))
        depth += chunk.end_with?('{') ? 1 : -1
        content << chunk
      end

      if depth.zero?
        parts << [:note, content.delete_suffix('}'), true]
      else
        content << scanner.rest
        scanner.terminate
        parts << [:note, content, false]
      end
    end

    parts
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
