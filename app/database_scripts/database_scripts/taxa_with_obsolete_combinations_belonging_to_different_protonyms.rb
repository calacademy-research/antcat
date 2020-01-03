module DatabaseScripts
  class TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms < DatabaseScript
    def results
      current_valid_taxa_of_obsolete_combinations.joins(:obsolete_combinations).
        where("taxa.protonym_id <> obsolete_combinations_taxa.protonym_id").distinct
    end

    private

      def current_valid_taxa_of_obsolete_combinations
        current_valid_taxon_ids = Taxon.obsolete_combinations.select(:current_valid_taxon_id)
        Taxon.where(id: current_valid_taxon_ids)
      end
  end
end

__END__

category: Catalog
tags: []

issue_description: This taxon has an obsolete combination that belongs to a different protonym.

description: >
  Click on a taxon to see the obsolete combinations in the catalog.


  This script is the reverse of %dbscript:ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym

related_scripts:
  - ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym
  - SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon
  - TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms
