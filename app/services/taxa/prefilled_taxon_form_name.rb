module Taxa
  class PrefilledTaxonFormName
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      base = case taxon
             when Subgenus, Species then taxon.genus
             when Subspecies        then taxon.species
             when Infrasubspecies   then taxon.subspecies
             end
      return unless base
      base.name.name + ' '
    end

    private

      attr_reader :taxon
  end
end
