# frozen_string_literal: true

module DatabaseScripts
  class ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentTaxonsProtonym < DatabaseScript
    def results
      Taxon.where(type: Rank::SPECIES_GROUP_NAMES).obsolete_combinations.joins(:current_taxon).
        where("taxa.protonym_id <> current_taxons_taxa.protonym_id").
        includes(protonym: [:name], current_taxon: { protonym: [:name] })
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status', 'current_taxon',
          'current_taxon status', 'Taxon epithet', 'current_taxon epithet',
          'Probably change CT?',
          'Probably change status to synonym?'

        t.rows do |taxon|
          current_taxon = taxon.current_taxon
          ct_cleanup_taxon = Taxa::CleanupTaxon.new(current_taxon)

          [
            taxon_link(taxon),
            taxon.type,
            taxon.status,
            taxon_link(current_taxon),
            current_taxon.status,
            taxon.name.epithet,
            current_taxon.name.epithet,

            ('Yes' if ct_cleanup_taxon.synonyms_history_items_containing_taxons_protonyms_taxa_except_self(taxon).present?),
            ('Yes' if ct_cleanup_taxon.synonyms_history_items_containing_taxon(taxon).present?)
          ]
        end
      end
    end
  end
end

__END__

title: Obsolete combinations with protonyms not matching its current taxon's protonym

section: reversed
category: Catalog
tags: [slow-render, regression-test]

issue_description: This obsolete combination and its `current_taxon` do not share the same protonym.

description: >
  "Yes" in the "Taxon or protonym taxon in synonyms list?" means that the status should probably be changed to 'synonym'.
  More specifically it means that either the taxon itself (left-most column) or a taxon record belonging to its
  protonym appears in a "synonyms history item" owned by the current taxon. Open the taxon in the catalog to
  see the history item. If this is the case, then these could be fixed by script.


  Records in this script also often appears in %dbscript:ObsoleteCombinationsWithVeryDifferentEpithets


  This script is the reverse of %dbscript:TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms

related_scripts:
  - ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentTaxonsProtonym
  - SynonymsBelongingToTheSameProtonymAsItsCurrentTaxon
