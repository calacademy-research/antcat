# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems < DatabaseScript
    def self.looks_like_a_false_positive? protonym
      Protonym.all_taxa_above_genus_and_of_unique_different_ranks?(protonym.taxa) ||
        Protonym.taxa_genus_and_subgenus_pair?(protonym.taxa)
    end

    def results
      Protonym.distinct.joins(:taxa).
        where(taxa: { id: Taxon.joins(:history_items).select(:id) }).
        group("protonyms.id").having("COUNT(protonyms.id) > 1")
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Ranks of taxa', 'Taxa', 'Statuses of taxa', 'Looks like a false positive?'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.taxa.distinct.pluck(:type).join(', '),
            taxa_list(protonym.taxa),
            protonym.taxa.map(&:status).join('<br>'),
            (self.class.looks_like_a_false_positive?(protonym) ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end
  end
end

__END__

section: main
category: Protonyms

issue_description: More than one of this protonym's taxa have history items.

description: >
  Go to the protonym's page to see all history items in one place.

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
