# frozen_string_literal: true

# This is a dumping ground for temporary code used for cleaning up records.
# No tests is a feature, not a bug, since the only reason we're OK
# with this is because all of it will 100% be removed at some point :)

module Taxa
  class CleanupTaxon < SimpleDelegator
    def combination_in_according_to_history_items
      @_combination_in_according_to_history_items ||= begin
        ids = combination_in_history_items.map(&:ids_from_tax_or_taxac_tags).flatten
        Taxon.where(id: ids)
      end
    end

    private

      # "Combination in {tax 123}".
      # NOTE: Can be removed once we have normalized all 'combination in's.
      def combination_in_history_items
        protonym_history_items.where('taxt LIKE ?', "Combination in%")
      end
  end
end
