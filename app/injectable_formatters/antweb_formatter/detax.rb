# frozen_string_literal: true

module AntwebFormatter
  class Detax
    include ActionView::Helpers::SanitizeHelper
    include Service

    def initialize content
      @content = content.try(:dup)
      @formatter = AntwebFormatter
    end

    # Parses "example {tax 429361}"
    # into   "example <a href=\"https://antcat.org/catalog/429361\">Melophorini</a>"
    def call
      return unless content

      parse_tax_tags
      parse_taxac_tags

      parse_pro_tags
      parse_proac_tags

      parse_ref_tags

      parse_missing_or_unmissing_tags
      parse_misspelling_tags

      parse_hiddennotes_tags

      sanitize content.html_safe
    end

    private

      attr_reader :content, :formatter

      # Taxa, "{tax 123}".
      def parse_tax_tags
        content.gsub!(Taxt::TAX_TAG_REGEX) do
          if (taxon = Taxon.find_by(id: $LAST_MATCH_INFO[:id]))
            formatter.link_to_taxon(taxon)
          end
        end
      end

      # Taxa with author citation, "{taxac 123}".
      def parse_taxac_tags
        content.gsub!(Taxt::TAXAC_TAG_REGEX) do
          if (taxon = Taxon.find_by(id: $LAST_MATCH_INFO[:id]))
            formatter.link_to_taxon_with_author_citation(taxon)
          end
        end
      end

      # References, "{ref 123}".
      def parse_ref_tags
        content.gsub!(Taxt::REF_TAG_REGEX) do
          if (reference = Reference.find_by(id: $LAST_MATCH_INFO[:id]))
            formatter.link_to_reference(reference)
          end
        end
      end

      # Protonyms, "{pro 123}".
      def parse_pro_tags
        content.gsub!(Taxt::PRO_TAG_REGEX) do
          if (protonym = Protonym.find_by(id: $LAST_MATCH_INFO[:id]))
            formatter.link_to_protonym(protonym)
          end
        end
      end

      # Protonyms with author citation, "{proac 123}".
      def parse_proac_tags
        content.gsub!(Taxt::PROAC_TAG_REGEX) do
          if (protonym = Protonym.find_by(id: $LAST_MATCH_INFO[:id]))
            formatter.link_to_protonym_with_author_citation(protonym)
          end
        end
      end

      # Hardcoded names, "{missing/unmissing string}".
      def parse_missing_or_unmissing_tags
        content.gsub!(Taxt::MISSING_OR_UNMISSING_TAG_REGEX) do
          $LAST_MATCH_INFO[:hardcoded_name]
        end
      end

      # Misspelled hardcoded names, "{misspelling string}".
      def parse_misspelling_tags
        content.gsub!(Taxt::MISSPELLING_TAG_REGEX) do
          $LAST_MATCH_INFO[:hardcoded_name]
        end
      end

      # Hidden editor notes (logged-in only) "{hiddennote string}".
      def parse_hiddennotes_tags
        content.gsub!(Taxt::HIDDENNOTE_TAG_REGEX) do
          ''
        end
      end
  end
end
