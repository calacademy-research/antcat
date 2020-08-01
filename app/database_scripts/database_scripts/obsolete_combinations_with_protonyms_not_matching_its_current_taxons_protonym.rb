# frozen_string_literal: true

module DatabaseScripts
  class ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentTaxonsProtonym < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED_REVERSED
    end

    def results
      Taxon.where(type: Rank::SPECIES_GROUP_NAMES).obsolete_combinations.joins(:current_taxon).
        where("taxa.protonym_id <> current_taxons_taxa.protonym_id").
        includes(protonym: [:name], current_taxon: { protonym: [:name] })
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status', 'current_taxon',
          'current_taxon status', 'Taxon epithet', 'current_taxon epithet'

        t.rows do |taxon|
          current_taxon = taxon.current_taxon
          [
            taxon_link(taxon),
            taxon.type,
            taxon.status,
            taxon_link(current_taxon),
            current_taxon.status,
            taxon.name.epithet,
            current_taxon.name.epithet
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
  This script is the reverse of %dbscript:TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms

related_scripts:
  - ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentTaxonsProtonym
  - ObsoleteCombinationsWithVeryDifferentEpithets
  - SynonymsBelongingToTheSameProtonymAsItsCurrentTaxon
