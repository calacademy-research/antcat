# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithMoreThanOneValidTaxon < DatabaseScript
    def self.looks_like_a_false_positive? protonym
      Protonyms.all_taxa_above_genus_and_of_unique_different_ranks?(protonym.taxa.valid) ||
        Protonyms.taxa_genus_and_subgenus_pair?(protonym.taxa.valid)
    end

    def empty_status
      DatabaseScripts::EmptyStatus::FALSE_POSITIVES
    end

    def results
      Protonym.joins(:taxa).where(taxa: { status: Status::VALID }).group('protonyms.id').having('COUNT(protonym_id) > 1')
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Ranks of taxa', 'Looks like a false positive?'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.author_citation,
            protonym.taxa.pluck(:type).join(', '),
            (self.class.looks_like_a_false_positive?(protonym) ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Protonyms
tags: []

issue_description: This protonym has more than one taxon with the status valid.

description: >
   It is fine for a protonym to have more than one valid taxa if it is above the rank of
   genus (one valid taxa in rank: tribe, subfamily or family).

related_scripts:
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithMoreThanOneSpeciesInTheSameGenus
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithIncompatibleStatuses
  - ProtonymsWithTaxaWithMoreThanOneCurrentTaxon
