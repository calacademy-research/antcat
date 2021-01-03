# frozen_string_literal: true

# TMPCLEANUP: Temporary code for `QuickAndDirtyFixesController#convert_to_taxac_tags`.
module QuickAndDirtyFixes
  class ConvertTaxToTaxacTags
    include Service

    def initialize taxt
      @taxt = taxt
    end

    def call
      convert_tax_to_taxac_tags
    end

    private

      attr_reader :taxt

      # Copy-pasted from `HistoryItemsWithRefTagsAsAuthorCitations`.
      def convert_tax_to_taxac_tags
        ids = taxt.scan(/\{#{Taxt::TAX_TAG} (?<tax_id>[0-9]+)\}:? \{#{Taxt::REF_TAG} (?<ref_id>[0-9]+)\}:/o)

        string = taxt.dup

        ids.each do |(tax_id, ref_id)|
          taxon = Taxon.find(tax_id)
          reference = Reference.find(ref_id)
          next unless taxon.authorship_reference == reference

          string.gsub!(
            /\{#{Taxt::TAX_TAG} #{tax_id}\}:? \{#{Taxt::REF_TAG} #{ref_id}\}:/,
            "{#{Taxt::TAXAC_TAG} #{tax_id}}:"
          )
        end

        string
      end
  end
end
