module DatabaseScripts
  class ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentValidTaxon < DatabaseScript
    def results
      Taxon.obsolete_combinations.joins(:current_valid_taxon).where("current_valid_taxons_taxa.fossil <> taxa.fossil").
        includes(:current_valid_taxon)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :fossil_status, :current_valid_taxon, :current_valid_taxon_status, :current_valid_taxon_fossil_status
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,
            (taxon.fossil? ? 'fossil' : 'extant'),

            markdown_taxon_link(current_valid_taxon),
            current_valid_taxon.status,
            (current_valid_taxon.fossil? ? 'fossil' : 'extant')
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [new!]

issue_description: This obsolete combination does not have the same fossil status as its `current_valid_taxon`.

description: >

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentValidTaxon
