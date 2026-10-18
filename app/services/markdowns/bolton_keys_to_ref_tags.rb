# frozen_string_literal: true

module Markdowns
  class BoltonKeysToRefTags
    include Service

    # Bolton's reference lists are short; these caps keep one request from running a huge number of lookups.
    MAX_CONTENT_LENGTH = 20_000 # Characters.
    MAX_BOLTON_KEYS = 500 # "Key:" fragments in one conversion.
    BOLTON_KEY_REGEX = /(?<bolton_key>.*?):/

    class TooLarge < StandardError
    end

    attr_private_initialize :bolton_content

    def call
      raise TooLarge, "content longer than #{MAX_CONTENT_LENGTH} characters" if bolton_content.to_s.length > MAX_CONTENT_LENGTH

      replace_with_ref_tags
    end

    private

      def replace_with_ref_tags
        parts = split_by_semicolon
        references_by_key = find_references(parts)

        parts.map do |part|
          part.gsub(BOLTON_KEY_REGEX) do
            reference_id = references_by_key[normalize_bolton_key($LAST_MATCH_INFO[:bolton_key])]
            if reference_id
              "#{Taxt.ref(reference_id)}:"
            else
              "#{Regexp.last_match(1)}: "
            end
          end
        end.join("; ").gsub("  ", " ")
      end

      def split_by_semicolon
        bolton_content.to_s.split("; ")
      end

      # One query for all keys. Returns { normalized key => reference id }.
      def find_references parts
        keys = parts.flat_map { |part| part.scan(BOLTON_KEY_REGEX).flatten }.map { normalize_bolton_key(it) }
        raise TooLarge, "more than #{MAX_BOLTON_KEYS} Bolton keys" if keys.size > MAX_BOLTON_KEYS

        keys = keys.compact_blank.uniq
        return {} if keys.empty?

        rows = Reference.where(bolton_key: keys).order(:id).pluck(:bolton_key, :id)
        keys.index_with { |key| matching_reference_id(rows, key) }.compact
      end

      # The database compares keys case-insensitively (and ignores trailing spaces), like the single
      # `find_by(bolton_key: ...)` this replaces; an exact match is preferred. The first (lowest id) wins.
      def matching_reference_id rows, key
        exact = rows.find { |bolton_key, _id| bolton_key == key }
        return exact.last if exact

        rows.find { |bolton_key, _id| comparable(bolton_key) == comparable(key) }&.last
      end

      def comparable bolton_key
        I18n.transliterate(bolton_key.to_s).downcase.rstrip
      end

      def normalize_bolton_key bolton_key
        bolton_key.remove(",", "&").gsub("  ", " ").strip
      end
  end
end
