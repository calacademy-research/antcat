# frozen_string_literal: true

# TMPCLEANUP: Temporary code for `QuickAndDirtyFixesController#remove_pages_from_taxac_tags`.
# NOTE: Difference from `RemovePagesFromTaxacTags` is that we don't check if hardcoded pages match the pages of the authorship.
module QuickAndDirtyFixes
  class ForceRemovePagesFromTaxacTags
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

        ids.each do |(taxac_id, _pages)|
          string.gsub!(
            /\{#{Taxt::TAXAC_TAG} #{taxac_id}\}: [0-9]+/,
            "{#{Taxt::TAXAC_TAG} #{taxac_id}}"
          )
        end

        string
      end
  end
end
