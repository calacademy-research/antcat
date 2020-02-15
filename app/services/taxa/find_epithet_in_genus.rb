module Taxa
  class FindEpithetInGenus
    include Service

    def initialize genus, target_epithet_string
      @genus = genus
      @target_epithet_string = target_epithet_string
    end

    def call
      raise unless genus.is_a?(Genus) # TODO: Sanity check, not tested.
      SpeciesGroupTaxon.joins(:name).where(genus: genus).where(names: { epithet: epithet_search_set })
    end

    private

      attr_reader :genus, :target_epithet_string

      def epithet_search_set
        Names::EpithetSearchSet[target_epithet_string]
      end
  end
end
