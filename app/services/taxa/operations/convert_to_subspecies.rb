module Taxa
  module Operations
    class ConvertToSubspecies
      include Service

      def initialize original_species, new_species_parent
        @original_species = original_species
        @new_species_parent = new_species_parent
      end

      def call
        # TODO: Revisit after converting broken subspecies to infrasubspecies.
        raise Taxon::TaxonHasInfrasubspecies, 'Species has infrasubspecies' if original_species.infrasubspecies.any?

        return false if original_species.subspecies.exists?
        raise unless original_species.is_a?(Species) && new_species_parent.is_a?(Species)

        new_subspecies = build_new_subspecies

        if Taxon.name_clash?(new_subspecies.name.name)
          new_subspecies.errors.add :base, "This name is in use by another taxon"
          return new_subspecies
        end

        if new_subspecies.save
          move_history_items! new_subspecies
        end

        new_subspecies
      end

      private

        attr_reader :original_species, :new_species_parent

        def build_new_subspecies
          taxon = Subspecies.new
          taxon.attributes = Taxa::CopyAttributes[original_species]
          taxon.species = new_species_parent
          taxon.name = subspecies_name
          taxon
        end

        def subspecies_name
          new_name_string = "#{new_species_parent.genus.name.name} #{new_species_parent.name.epithet} #{original_species.name.epithet}"

          SubspeciesName.new(name: new_name_string)
        end

        def move_history_items! new_subspecies
          Taxa::Operations::MoveItems[new_subspecies, original_species.history_items]
        end
    end
  end
end
