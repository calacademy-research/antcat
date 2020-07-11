# frozen_string_literal: true

module DatabaseScripts
  class TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms < DatabaseScript
    def results
      current_taxa_of_obsolete_combinations.joins(:obsolete_combinations).
        where("taxa.protonym_id <> obsolete_combinations_taxa.protonym_id").distinct
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Obsolete combinations'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.status,
            taxon_links(taxon.obsolete_combinations)
          ]
        end
      end
    end

    private

      def current_taxa_of_obsolete_combinations
        current_taxon_ids = Taxon.obsolete_combinations.select(:current_taxon_id)
        Taxon.where(id: current_taxon_ids)
      end
  end
end

__END__

section: main
category: Catalog
tags: [has-reversed]

issue_description: This taxon has an obsolete combination that belongs to a different protonym.

description: >
  Click on a taxon to see the obsolete combinations in the catalog.


  This script is the reverse of %dbscript:ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentTaxonsProtonym

related_scripts:
  - SynonymsBelongingToTheSameProtonymAsItsCurrentTaxon
  - TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms
