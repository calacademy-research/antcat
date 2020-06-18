# frozen_string_literal: true

module DatabaseScripts
  class ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentTaxon < DatabaseScript
    def results
      Taxon.obsolete_combinations.joins(:current_taxon).where("current_taxons_taxa.fossil <> taxa.fossil").
        includes(:current_taxon)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Locality', 'Fossil status',
          'current_taxon', 'CVT status', 'CVT locality', 'CVT fossil status'
        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.status,
            taxon.protonym.locality,
            (taxon.fossil? ? 'fossil' : 'extant'),

            taxon_link(current_taxon),
            current_taxon.status,
            current_taxon.protonym.locality,
            (current_taxon.fossil? ? 'fossil' : 'extant')
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Catalog
tags: []

issue_description: This obsolete combination does not have the same fossil status as its `current_taxon`.

description: >

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentTaxon
