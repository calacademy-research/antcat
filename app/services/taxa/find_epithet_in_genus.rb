# frozen_string_literal: true

module Taxa
  class FindEpithetInGenus
    include Service

    attr_private_initialize :genus, :target_epithet_string

    def call
      raise unless genus.is_a?(Genus) # TODO: Sanity check, not tested.
      SpeciesGroupTaxon.joins(:name).where(genus: genus).where(names: { epithet: epithet_search_set })
    end

    private

      def epithet_search_set
        Names::EpithetSearchSet[target_epithet_string]
      end
  end
end
