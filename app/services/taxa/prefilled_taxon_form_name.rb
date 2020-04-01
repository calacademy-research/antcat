# frozen_string_literal: true

module Taxa
  class PrefilledTaxonFormName
    include Service

    attr_private_initialize :taxon

    def call
      base = case taxon
             when Subgenus, Species then taxon.genus
             when Subspecies        then taxon.species
             when Infrasubspecies   then taxon.subspecies
             end
      return unless base
      base.name.name + ' '
    end
  end
end
