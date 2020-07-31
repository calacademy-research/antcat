# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithMoreThanOneSpeciesInTheSameGenus < DatabaseScript
    def self.record_in_results? protonynm
      protonynm.taxa.where(type: Rank::SPECIES).joins(:name).
        group("SUBSTRING_INDEX(names.name, ' ', 1)").
        having("COUNT(taxa.id) > 1").exists?
    end

    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED_REVERSED
    end

    def results
      dups = Species.joins(:name).
        where.not(status: Status::UNAVAILABLE_MISSPELLING).
        group("protonym_id, SUBSTRING_INDEX(names.name, ' ', 1)").having("COUNT(taxa.id) > 1")
      Protonym.where(id: dups.select(:protonym_id))
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Taxa'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.author_citation,
            taxon_links(protonym.taxa)
          ]
        end
      end
    end
  end
end

__END__

section: reversed
category: Catalog
tags: []

description: >
  This script is the reverse of %dbscript:SpeciesWithGeneraAppearingMoreThanOnceInItsProtonym

issue_description: This protonym has more than one species in the same genus.

related_scripts:
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithMoreThanOneSpeciesInTheSameGenus
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithIncompatibleStatuses
  - ProtonymsWithTaxaWithMoreThanOneCurrentTaxon
