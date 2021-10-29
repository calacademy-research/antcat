# frozen_string_literal: true

module Taxa
  module Operations
    class ElevateToSpecies
      include Service

      attr_private_initialize :subspecies

      def call
        raise Taxa::TaxonHasInfrasubspecies, 'Subspecies has infrasubspecies' if subspecies.infrasubspecies.any?

        new_species = build_new_species

        if Taxa::NameClash[new_species.name.name]
          new_species.errors.add :base, "This name is in use by another taxon"
          return new_species
        end

        new_species.save
        new_species
      end

      private

        def build_new_species
          taxon = Species.new
          taxon.attributes = Taxa::CopyAttributes[subspecies]

          taxon.subfamily = subspecies.subfamily
          taxon.genus = subspecies.genus

          taxon.name = species_name
          taxon
        end

        def species_name
          species = subspecies.species
          new_name_string = "#{species.genus.name.name} #{subspecies.name.epithet}"

          SpeciesName.new(name: new_name_string)
        end
    end
  end
end
