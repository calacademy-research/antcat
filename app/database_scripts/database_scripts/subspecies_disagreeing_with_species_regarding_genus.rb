module DatabaseScripts
  class SubspeciesDisagreeingWithSpeciesRegardingGenus < DatabaseScript
    def results
      Subspecies.self_join_on(:species).where("taxa_self_join_alias.genus_id != taxa.genus_id")
    end

    def render
      as_table do |t|
        t.header :subspecies, :status, :species, :genus_of_subspecies, :genus_of_species
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(taxon.species),
            markdown_taxon_link(taxon.genus),
            markdown_taxon_link(taxon.species.genus)
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [regression-test]

issue_description: This subspecies is not in the same genus as its species.

description: >
  This script lists subspecies where the `genus_id` does not match its species' `genus_id`.


  Note: It may or may not currently be possible to fix all records listed here.

related_scripts:
  - SpeciesDisagreeingWithGenusRegardingSubfamily
  - SubspeciesDisagreeingWithSpeciesRegardingGenus
  - SubspeciesDisagreeingWithSpeciesRegardingSubfamily
  - SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet
