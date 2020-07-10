# frozen_string_literal: true

module DatabaseScripts
  class ObsoleteCombinationsInRanksAboveSpecies < DatabaseScript
    def results
      Taxon.obsolete_combinations.where(type: Rank::ABOVE_SPECIES).includes(:current_taxon)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Rank', 'current_taxon', 'current_taxon status', 'current_taxon rank'
        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.status,
            taxon.type,

            taxon_link(current_taxon),
            current_taxon.status,
            current_taxon.type
          ]
        end
      end
    end
  end
end

__END__

section: research
category: Catalog
tags: [list]

description: >
  These can be ignored, they will be updated to the new status `obsolete classification` by script.
