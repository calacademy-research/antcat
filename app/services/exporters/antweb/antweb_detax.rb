# frozen_string_literal: true

module Exporters
  module Antweb
    class AntwebDetax
      include ActionView::Helpers::SanitizeHelper
      include Service

      def initialize taxt
        @taxt = taxt.try :dup
      end

      # Parses "example {tax 429361}"
      # into   "example <a href=\"https://antcat.org/catalog/429361\">Melophorini</a>"
      def call
        return unless taxt

        parse_taxon_ids!
        parse_taxon_with_author_citation_ids!
        parse_reference_ids!

        sanitize taxt.html_safe
      end

      private

        attr_reader :taxt

        # Taxa, "{tax 123}".
        def parse_taxon_ids!
          taxt.gsub!(Taxt::ANTWEB_TAX_TAG_REGEX) do
            taxon = Taxon.find_by(id: Regexp.last_match(1))

            if taxon
              AntwebFormatter.link_to_taxon(taxon)
            end
          end
        end

        # Taxa with author citation, "{taxac 123}".
        def parse_taxon_with_author_citation_ids!
          taxt.gsub!(Taxt::ANTWEB_TAXAC_TAG_REGEX) do
            taxon = Taxon.find_by(id: Regexp.last_match(1))

            if taxon
              AntwebFormatter.link_to_taxon_with_author_citation(taxon)
            end
          end
        end

        # References, "{ref 123}".
        def parse_reference_ids!
          taxt.gsub!(Taxt::ANTWEB_REF_TAG_REGEX) do
            reference = Reference.find_by(id: Regexp.last_match(1))

            if reference
              Exporters::Antweb::AntwebInlineCitation[reference]
            end
          end
        end
    end
  end
end
