module DatabaseScripts
  class SubspeciesDisagreeingWithSpeciesRegardingSubfamily < DatabaseScript
    def results
      Subspecies.self_join_on(:species).where("taxa_self_join_alias.subfamily_id != taxa.subfamily_id")
    end

    def render
      as_table do |t|
        t.header :subspecies, :status, :species, :subfamily_of_subspecies, :subfamily_of_species
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(taxon.species),
            markdown_taxon_link(taxon.subfamily),
            markdown_taxon_link(taxon.species.subfamily)
          ]
        end
      end
    end
  end
end

__END__

description: >
  Note: It may or may not currently be possible to fix all records listed here.

tags: [new!]
topic_areas: [catalog]
issue_description: This subspecies is not in the same subfamily as its species.
related_scripts:
  - SpeciesDisagreeingWithGenusRegardingSubfamily
  - SubspeciesDisagreeingWithSpeciesRegardingGenus
  - SubspeciesDisagreeingWithSpeciesRegardingSubfamily
  - SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet
