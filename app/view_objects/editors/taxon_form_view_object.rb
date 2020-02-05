module Editors
  class TaxonFormViewObject < ViewObject
    def initialize taxon
      @taxon = taxon
    end

    def default_name_string
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
