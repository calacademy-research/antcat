module DatabaseScripts
  class ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym < DatabaseScript
    def results
      taxa_with_obsolete_combinations.joins(:obsolete_combinations).
        where("taxa.protonym_id <> obsolete_combinations_taxa.protonym_id").distinct
    end

    private

      def taxa_with_obsolete_combinations
        obsolete_combinations = Taxon.where.not(current_valid_taxon_id: nil).
          where(status: Status::OBSOLETE_COMBINATION).select(:current_valid_taxon_id)
        Taxon.where(id: obsolete_combinations)
      end
  end
end

__END__

title: Obsolete combinations with protonyms not matching its current valid taxon's protonym
category: Catalog
tags: [new!, slow]

description: >
  This script shows taxa that are set at the `current_valid_taxon` of other taxa.
  Click on a taxon to see the obsolete combinations on the catalog page.
