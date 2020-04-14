# frozen_string_literal: true

module DatabaseScripts
  class ValidSubspeciesInInvalidSpecies < DatabaseScript
    def results
      Subspecies.valid.joins(:species).where.not(species_taxa: { status: Status::VALID })
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
