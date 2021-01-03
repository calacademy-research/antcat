# frozen_string_literal: true

# TMPCLEANUP: Temporary code for `QuickAndDirtyFixesController#remove_pages_from_taxac_tags`.
module QuickAndDirtyFixes
  class RemovePagesFromTaxacTags
    include Service

    def initialize taxt
      @taxt = taxt
    end

    def call
      remove_page_numbers_from_taxac_tags
    end

    private

      attr_reader :taxt

      def remove_page_numbers_from_taxac_tags
        ids = taxt.scan(/\{#{Taxt::TAXAC_TAG} (?<taxac_id>[0-9]+)\}: (?<pages>[0-9]+)/o)

        string = taxt.dup

        ids.each do |(taxac_id, pages)|
          taxon = Taxon.find(taxac_id)
          next unless taxon.authorship.pages == pages

          string.gsub!(
            /\{#{Taxt::TAXAC_TAG} #{taxac_id}\}: [0-9]+/,
            "{#{Taxt::TAXAC_TAG} #{taxac_id}}"
          )
        end

        string
      end
  end
end
