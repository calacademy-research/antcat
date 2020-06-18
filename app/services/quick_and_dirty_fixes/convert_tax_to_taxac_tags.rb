# frozen_string_literal: true

# TODO: Temporary code for `QuickAndDirtyFixesController#convert_to_taxac_tags`.
# :nocov:
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
        ids = taxt.scan(/\{tax (?<tax_id>[0-9]+)\} \{ref (?<ref_id>[0-9]+)\}:/)

        string = taxt.dup

        ids.each do |(tax_id, ref_id)|
          taxon = Taxon.find(tax_id)
          reference = Reference.find(ref_id)
          next unless taxon.authorship_reference == reference

          string.gsub!(
            /\{tax #{tax_id}\} \{ref #{ref_id}\}:/,
            "{taxac #{tax_id}}:"
          )
        end

        string
      end
  end
end
# :nocov:
