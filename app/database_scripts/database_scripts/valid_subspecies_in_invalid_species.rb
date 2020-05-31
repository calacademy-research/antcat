# frozen_string_literal: true

module DatabaseScripts
  class ValidSubspeciesInInvalidSpecies < DatabaseScript
    def results
      Subspecies.valid.joins(:species).where.not(species_taxa: { status: Status::VALID })
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.rank,
            taxon.status
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Catalog
tags: []

issue_description: This subspecies is valid, but its species is not valid.

description: >

related_scripts:
  - ValidSubspeciesInInvalidSpecies
