module DatabaseScripts
  class ValidSubspeciesInInvalidSpecies < DatabaseScript
    def results
      Subspecies.valid.self_join_on(:species).where.not(taxa_self_join_alias: { status: Status::VALID })
    end
  end
end

__END__

category: Catalog
tags: [new!]

issue_description: This subspecies is valid, but its species is not valid.

description: >

related_scripts:
  - ValidSubspeciesInInvalidSpecies
