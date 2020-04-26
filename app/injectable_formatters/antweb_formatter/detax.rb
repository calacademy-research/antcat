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
      parse_ref_tags

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
  end
end
