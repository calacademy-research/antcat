module DatabaseScripts
  class SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet < DatabaseScript
    def results
      Subspecies.joins(:name).joins(:species).
        joins("JOIN names species_names ON species_names.id = species_taxa.name_id").
        where(<<~SQL)
          SUBSTRING_INDEX(SUBSTRING_INDEX(names.name, ' ', 2), ' ', -1) !=
          SUBSTRING_INDEX(SUBSTRING_INDEX(species_names.name, ' ', 2), ' ', -1)
        SQL
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :species_name
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.species.name_html_cache
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [regression-test]

issue_description: The species epithet of this subspecies is not the same as its species' epithet.

description: >
  This script compares names in name records (not taxa IDs such as `species_id`, `subspecies_id` or `subfamily_id`).


  See "Name (from name record)" in the "Additional data for editors" section in the catalog to figure out what's incorrect.
  The name from the name record also appears in the breadcrumb.


  The name in the catalog (preceding the author citation) is generated from a taxon's parent, and paren't parent.

related_scripts:
  - SpeciesDisagreeingWithGenusRegardingSubfamily
  - SubspeciesDisagreeingWithSpeciesRegardingGenus
  - SubspeciesDisagreeingWithSpeciesRegardingSubfamily
  - SpeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet
  - SubspeciesWithSpeciesEpithetsNotMatchingItsSpeciesEpithet
