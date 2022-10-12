# frozen_string_literal: true

module Taxa
  class PrefilledTaxonFormName
    include Service

    attr_private_initialize :taxon

    def call
      return unless (base = parent_with_reusable_name)
      base.name.name + ' '
    end

    private

      def parent_with_reusable_name
        case taxon
        when Subgenus, Species then taxon.genus
        when Subspecies        then taxon.species
        when Infrasubspecies   then taxon.subspecies
        end
      end
  end
end
