# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon < DatabaseScript
    def results
      Protonym.joins(:taxa).
        where.not(taxa: { status: [Status::OBSOLETE_COMBINATION, Status::UNAVAILABLE_MISSPELLING] }).
        group('protonyms.id').having("COUNT(DISTINCT taxa.current_valid_taxon_id) > 1")
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Ranks of taxa', 'Statuses of taxa'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', ')
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

issue_description: This protonym has taxa with different `current_valid_taxon`s (obsolete combinations excluded).

description: >
  Obsolete combinations and unavailable misspellings are excluded.

related_scripts:
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithMoreThanOneSpeciesInTheSameGenus
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithIncompatibleStatuses
  - ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon
  - ProtonymsWithTaxaWithMoreThanOneTypeTaxon

  - TypeTaxaAssignedToMoreThanOneTaxon
