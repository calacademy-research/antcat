# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithMoreThanOneValidTaxonOrSynonym < DatabaseScript
    def self.looks_like_a_false_positive? protonym
      Protonyms.all_taxa_above_genus_and_of_unique_different_ranks?(protonym.taxa) ||
        Protonyms.taxa_genus_and_subgenus_pair?(protonym.taxa)
    end

    def results
      Protonym.joins(:taxa).
        where(taxa: { status: [Status::VALID, Status::SYNONYM] }).
        group('protonyms.id').having('COUNT(protonym_id) > 1').
        where.not(id: covered_in_related_scripts)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Ranks of taxa', 'Statuses of taxa', 'Looks like a false positive?'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.author_citation,
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', '),
            (self.class.looks_like_a_false_positive?(protonym) ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end

    private

      def covered_in_related_scripts
        DatabaseScripts::ProtonymsWithMoreThanOneValidTaxon.new.results.select(:id) +
          DatabaseScripts::ProtonymsWithMoreThanOneSynonym.new.results.select(:id)
      end
  end
end

__END__

section: regression-test
category: Protonyms
tags: []

description: >
  Matches already appearing in these two scripts are excluded:


  * %dbscript:ProtonymsWithMoreThanOneSynonym

  * %dbscript:ProtonymsWithMoreThanOneValidTaxon

related_scripts:
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithMoreThanOneSpeciesInTheSameGenus
  - ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithIncompatibleStatuses
  - ProtonymsWithTaxaWithMoreThanOneCurrentTaxon
