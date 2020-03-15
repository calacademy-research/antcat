module DatabaseScripts
  class SubspeciesWithGenusEpithetsNotMatchingItsGenusEpithet < DatabaseScript
    def results
      Subspecies.joins(:name).joins(:genus).
        joins("JOIN names genus_names ON genus_names.id = genera_taxa.name_id").
        where("SUBSTRING_INDEX(names.name, ' ', 1) != genus_names.name")
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Genus name'
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

category: Catalog
tags: [regression-test]

issue_description: The genus epithet of this subspecies is not the same as its genus' epithet.

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
