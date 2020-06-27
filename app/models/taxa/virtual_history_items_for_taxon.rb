# frozen_string_literal: true

module Taxa
  class VirtualHistoryItemsForTaxon
    include Service

    FOR_RANK = {
      Rank::SPECIES => [
        VirtualHistoryItems::SubspeciesList
      ]
    }

    attr_private_initialize :taxon

    def call
      all_relevant
    end

    private

      def all_relevant
        for_rank.map { |klass| klass.new(taxon) }.select(&:relevant_for_taxon?)
      end

      def for_rank
        FOR_RANK[taxon.type] || []
      end
  end
end
