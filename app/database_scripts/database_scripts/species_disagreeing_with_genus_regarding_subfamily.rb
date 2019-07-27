module DatabaseScripts
  class SpeciesDisagreeingWithGenusRegardingSubfamily < DatabaseScript
    def results
      Species.self_join_on(:genus).where("taxa_self_join_alias.subfamily_id != taxa.subfamily_id")
    end

    def render
      as_table do |t|
        t.header :species, :status, :genus, :subfamily_of_species, :subfamily_of_genus
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(taxon.genus),
            markdown_taxon_link(taxon.subfamily),
            markdown_taxon_link(taxon.genus.subfamily)
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
issue_description: This species is not in the same subfamily as its genus.
related_scripts:
  - SpeciesDisagreeingWithGenusRegardingSubfamily
  - SubspeciesDisagreeingWithSpeciesRegardingGenus
  - SubspeciesDisagreeingWithSpeciesRegardingSubfamily
  - SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet