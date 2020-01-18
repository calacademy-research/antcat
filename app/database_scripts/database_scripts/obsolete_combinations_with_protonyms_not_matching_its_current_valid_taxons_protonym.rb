module DatabaseScripts
  class ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym < DatabaseScript
    def results
      Taxon.obsolete_combinations.joins(:current_valid_taxon).
        where("taxa.protonym_id <> current_valid_taxons_taxa.protonym_id").
        includes(protonym: [:name], current_valid_taxon: { protonym: [:name] })
    end

    def render
      as_table do |t|
        t.header :taxon, :origin, :status, :protonym,
          :current_valid_taxon, :current_valid_taxon_status, :current_valid_taxon_protonym

        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            origin_warning(taxon),
            taxon.status,
            taxon.protonym.decorate.link_to_protonym,

            markdown_taxon_link(current_valid_taxon),
            current_valid_taxon.status,
            current_valid_taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

title: Obsolete combinations with protonyms not matching its current valid taxon's protonym
category: Catalog
tags: []

issue_description: This obsolete combination and its `current_valid_taxon` do not share the same protonym.

description: >
  This script is the reverse of %dbscript:TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms

related_scripts:
  - ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym
  - SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon
  - TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms
