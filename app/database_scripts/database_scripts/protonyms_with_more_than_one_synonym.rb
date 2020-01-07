module DatabaseScripts
  class ProtonymsWithMoreThanOneSynonym < DatabaseScript
    def self.looks_like_a_false_positive? protonym
      Protonym.all_taxa_above_genus_and_of_unique_different_ranks?(protonym.taxa)
    end

    def results
      Protonym.joins(:taxa).where(taxa: { status: Status::SYNONYM }).group(:protonym_id).having('COUNT(protonym_id) > 1')
    end

    def render
      as_table do |t|
        t.header :protonym, :authorship, :ranks_of_taxa, :looks_like_a_false_positive?
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.decorate.expandable_reference,
            protonym.taxa.pluck(:type).join(', '),
            (self.class.looks_like_a_false_positive?(protonym) ? 'Yes' : '<span class="bold-warning">No</span>')
          ]
        end
      end
    end
  end
end

__END__

category: Protonyms
tags: [new!]

issue_description: More than one of this protonym's taxa is a synonym.

description: >
   It is fine for a protonym to have more than one synonym if it is above the rank of
   genus (one valid taxa in rank: tribe, subfamily or family).

related_scripts:
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon
  - ProtonymsWithTaxaWithMoreThanOneTypeTaxon
  - TypeTaxaAssignedToMoreThanOneTaxon
