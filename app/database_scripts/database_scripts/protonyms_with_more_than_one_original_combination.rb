# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithMoreThanOneOriginalCombination < DatabaseScript
    def results
      Protonym.joins(:taxa).where(taxa: { original_combination: true }).group('protonyms.id').having('COUNT(taxa.id) > 1')
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

section: regression-test
category: Protonyms
tags: []

issue_description: This protonym has more than one original combination.

description: >
  Where "protonym" means `Protonym` record, and "original combination" means `Taxon` record where `original_combination` is true.

related_scripts:
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithMoreThanOneSpeciesInTheSameGenus
  - ProtonymsWithMoreThanOneSynonym
  - ProtonymsWithMoreThanOneValidTaxon
  - ProtonymsWithMoreThanOneValidTaxonOrSynonym
  - ProtonymsWithTaxaWithIncompatibleStatuses
  - ProtonymsWithTaxaWithMoreThanOneCurrentTaxon
