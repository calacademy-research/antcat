# frozen_string_literal: true

# TODO: Temporary code for `QuickAndDirtyFixesController#remove_pages_from_taxac_tags`.
# NOTE: Difference from `RemovePagesFromTaxacTags` is that we don't check if hardcoded pages match the pages of the authorship.
# :nocov:
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
        ids = taxt.scan(/\{taxac (?<taxac_id>[0-9]+)\}: (?<pages>[0-9]+)/)

        string = taxt.dup

        ids.each do |(taxac_id, _pages)|
          string.gsub!(
            /\{taxac #{taxac_id}\}: [0-9]+/,
            "{taxac #{taxac_id}}"
          )
        end

        string
      end
  end
end
# :nocov:
