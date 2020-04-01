# frozen_string_literal: true

module Taxa
  module Operations
    class ElevateToSpecies
      include Service

      attr_private_initialize :subspecies

      def call
        # TODO: Revisit after converting broken subspecies to infrasubspecies.
        raise Taxa::TaxonHasInfrasubspecies, 'Subspecies has infrasubspecies' if subspecies.infrasubspecies.any?

        new_species = build_new_species

        if Taxon.name_clash?(new_species.name.name)
          new_species.errors.add :base, "This name is in use by another taxon"
          return new_species
        end

        if new_species.save
          move_history_items! new_species
        end

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

        def move_history_items! new_species
          Taxa::Operations::MoveItems[new_species, subspecies.history_items]
        end
    end
  end
end
