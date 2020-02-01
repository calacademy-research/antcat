module DatabaseScripts
  class ProtonymsWithMoreThanOneSpeciesInTheSameGenus < DatabaseScript
    def results
      dups = Species.joins(:name).group("protonym_id, SUBSTRING_INDEX(names.name, ' ', 1)").having("COUNT(taxa.id) > 1")
      Protonym.where(id: dups.select(:protonym_id))
    end

    def render
      as_table do |t|
        t.header :protonym, :authorship, :taxa
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
            protonym.taxa.map { |tax| tax.link_to_taxon + origin_warning(tax).html_safe }.join('<br>')
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: []

description: >
  Some are misspellings, which I'm not sure how to handle (they do not fit the current database structure 100%).


  Other are obsolete combinations with different gender agreements -- these do commonly appear in print due to
  confusion over Latin grammar, but many cases on AntCat may simple be incorrect.


  There are also records with very different epithets; they also appear in %dbscript:ProtonymsWithTaxaWithVeryDifferentEpithets


  This script is the reverse of %dbscript:SpeciesWithGeneraAppearingMoreThanOnceInItsProtonym

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

  - SpeciesWithGeneraAppearingMoreThanOnceInItsProtonym
  - TypeTaxaAssignedToMoreThanOneTaxon
