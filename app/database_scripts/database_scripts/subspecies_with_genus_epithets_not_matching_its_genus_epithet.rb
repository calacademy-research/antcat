module DatabaseScripts
  class SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet < DatabaseScript
    def results
      Subspecies.joins(:name).self_join_on(:genus).
        joins("JOIN names genus_names ON genus_names.id = taxa_self_join_alias.name_id").
        where("SUBSTRING_INDEX(names.name, ' ', 1) != genus_names.name")
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :genus_name
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.genus.name_html_cache
          ]
        end
      end
    end
  end
end

__END__

description: >

tags: []
topic_areas: [catalog]
related_scripts:
  - SpeciesDisagreeingWithGenusRegardingSubfamily
  - SubspeciesDisagreeingWithSpeciesRegardingGenus
  - SubspeciesDisagreeingWithSpeciesRegardingSubfamily
  - SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet
