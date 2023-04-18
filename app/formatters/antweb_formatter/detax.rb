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
      parse_prott_tags
      parse_prottac_tags

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
          if (taxon = Taxon.find_by(id: $LAST_MATCH_INFO[:taxon_id]))
            formatter.link_to_taxon(taxon)
          end
        end
      end

      # Taxa with author citation, "{taxac 123}".
      def parse_taxac_tags
        content.gsub!(Taxt::TAXAC_TAG_REGEX) do
          if (taxon = Taxon.find_by(id: $LAST_MATCH_INFO[:taxon_id]))
            formatter.link_to_taxon_with_author_citation(taxon)
          end
        end
      end

      # Protonyms, "{pro 123}".
      def parse_pro_tags
        content.gsub!(Taxt::PRO_TAG_REGEX) do
          if (protonym = Protonym.find_by(id: $LAST_MATCH_INFO[:protonym_id]))
            formatter.link_to_protonym(protonym)
          end
        end
      end

      # Protonyms with author citation, "{proac 123}".
      def parse_proac_tags
        content.gsub!(Taxt::PROAC_TAG_REGEX) do
          if (protonym = Protonym.find_by(id: $LAST_MATCH_INFO[:protonym_id]))
            formatter.link_to_protonym_with_author_citation(protonym)
          end
        end
      end

      # Terminal taxon of protonyms, "{prott 123}".
      def parse_prott_tags
        content.gsub!(Taxt::PROTT_TAG_REGEX) do
          protonym_id = $LAST_MATCH_INFO[:protonym_id]

          if (terminal_taxon = Protonym.terminal_taxon_from_protonym_id(protonym_id))
            formatter.link_to_taxon(terminal_taxon)
          elsif (protonym = Protonym.find_by(id: protonym_id))
            formatter.link_to_protonym(protonym) + ' (protonym)'
          end
        end
      end

      # Terminal taxon of protonyms, with author citation, "{prottac 123}".
      def parse_prottac_tags
        content.gsub!(Taxt::PROTTAC_TAG_REGEX) do
          protonym_id = $LAST_MATCH_INFO[:protonym_id]

          if (terminal_taxon = Protonym.terminal_taxon_from_protonym_id(protonym_id))
            formatter.link_to_taxon_with_author_citation(terminal_taxon)
          elsif (protonym = Protonym.find_by(id: protonym_id))
            formatter.link_to_protonym(protonym) + ' (protonym)'
          end
        end
      end

      # References, "{ref 123}".
      def parse_ref_tags
        content.gsub!(Taxt::REF_TAG_REGEX) do
          if (reference = Reference.find_by(id: $LAST_MATCH_INFO[:reference_id]))
            formatter.link_to_reference(reference)
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
