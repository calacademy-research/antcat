# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithTaxaWithMoreThanOneTypeTaxon < DatabaseScript
    def self.looks_like_a_false_positive? protonym
      Protonym.all_taxa_above_genus_and_of_unique_different_ranks?(protonym.taxa) ||
        Protonym.taxa_genus_and_subgenus_pair?(protonym.taxa)
    end

    def results
      Protonym.joins(:taxa).where.not(taxa: { type_taxon_id: nil }).group(:protonym_id).having('COUNT(taxa.id) > 1')
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Ranks of taxa', 'Statuses of taxa',
          'All type taxa identical?', 'All type_taxt identical?', 'Looks like a false positive?'
        t.rows do |protonym|
          type_taxts = protonym.taxa.pluck(:type_taxt)
          type_taxts_identical = type_taxts.uniq.size == 1
          type_taxa_identical = protonym.taxa.pluck(:type_taxon_id).uniq.size == 1

          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
            protonym.taxa.pluck(:type).join(', '),
            protonym.taxa.pluck(:status).join(', '),
            (type_taxa_identical ? 'Yes' : bold_warning('No')),
            (type_taxts_identical ? 'Yes' : bold_warning('No')),
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
tags: []

issue_description: This protonym has taxa with more than one type taxon.

description: >
  For "No" in the "All type taxts idential?" column, see the protonym page.

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

  - ProtonymsWithoutTypeTaxa
  - TypeTaxaAssignedToMoreThanOneTaxon
