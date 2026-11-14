# frozen_string_literal: true

# A taxon and all its parents up to the family, in order.
module Taxa
  class TaxonAndAncestors
    include Service

    attr_private_initialize :taxon

    def call
      taxon_and_ancestors
    end

    private

      def taxon_and_ancestors
        taxa = []
        current_taxon = taxon

        while current_taxon
          taxa << current_taxon
          current_taxon = current_taxon.parent
        end

        taxa.reverse
      end
  end
end
