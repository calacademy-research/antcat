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
          :current_valid_taxon, :current_valid_taxon_status, :current_valid_taxon_protonym,
          :taxon_or_protonym_taxon_in_synonyms_list?

        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            origin_warning(taxon),
            taxon.status,
            taxon.protonym.decorate.link_to_protonym,

            markdown_taxon_link(current_valid_taxon),
            current_valid_taxon.status,
            current_valid_taxon.protonym.decorate.link_to_protonym,

            ('Yes' if taxon.current_valid_taxon.synonyms_history_items_containing_taxons_protonyms_taxa(taxon).present?)
          ]
        end
      end
    end
  end
end

__END__

title: Obsolete combinations with protonyms not matching its current valid taxon's protonym
category: Catalog
tags: [slow-render]

issue_description: This obsolete combination and its `current_valid_taxon` do not share the same protonym.

description: >
  "Yes" in the "Taxon or protonym taxon in synonyms list?" means that the status should probably be changed to 'synonym'.
  More specifically it means that either the taxon itself (left-most column) or a taxon record belonging to its
  protonym appears in a "synonyms history item" owned by the current valid taxon. Open the taxon in the catalog to
  see the history item. If this is the case, then these could be fixed by script.


  Records in this script also often appears in %dbscript:ObsoleteCombinationsWithVeryDifferentEpithets


  This script is the reverse of %dbscript:TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms

related_scripts:
  - ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym
  - SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon
  - TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms
