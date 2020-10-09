# frozen_string_literal: true

module Taxa
  module Operations
    class ConvertToSubspecies
      include Service

      attr_private_initialize :original_species, :new_species_parent

      def call
        return false unless policy.allowed?
        return false if original_species.subspecies.exists?
        raise unless original_species.is_a?(Species) && new_species_parent.is_a?(Species)

        new_subspecies = build_new_subspecies

        if Taxa::NameClash[new_subspecies.name.name]
          new_subspecies.errors.add :base, "This name is in use by another taxon"
          return new_subspecies
        end

        new_subspecies.save
        new_subspecies
      end

      private

        def policy
          ConvertToSubspeciesPolicy.new(original_species)
        end

        def build_new_subspecies
          taxon = Subspecies.new
          taxon.attributes = Taxa::CopyAttributes[original_species]

          taxon.subfamily = new_species_parent.subfamily
          taxon.genus = new_species_parent.genus
          taxon.species = new_species_parent

          taxon.name = subspecies_name
          taxon
        end

        def subspecies_name
          new_name_string = "#{new_species_parent.genus.name.name} #{new_species_parent.name.epithet} #{original_species.name.epithet}"

          SubspeciesName.new(name: new_name_string)
        end
    end
  end
end
