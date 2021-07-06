# frozen_string_literal: true

module Taxa
  module Operations
    class CreateObsoleteCombination
      include Service

      attr_private_initialize :current_taxon, :obsolete_genus

      def call
        # TODO: Raises are not tested nor handled because it should not happen but probably test anyways.
        raise "not allowed" unless current_taxon.policy.allow_create_obsolete_combination?
        raise "obsolete_genus must be a genus" unless obsolete_genus.is_a?(Genus)

        obsolete_combination = build_obsolete_combination

        if Taxa::NameClash[obsolete_combination.name.name]
          obsolete_combination.errors.add :base, "This name is in use by another taxon"
          return obsolete_combination
        end

        obsolete_combination.save
        obsolete_combination
      end

      private

        def build_obsolete_combination
          obsolete_combination = Species.new
          obsolete_combination.name = obsolete_combination_name
          obsolete_combination.protonym = current_taxon.protonym
          obsolete_combination.parent = obsolete_genus
          obsolete_combination.current_taxon = current_taxon
          obsolete_combination.status = Status::OBSOLETE_COMBINATION

          obsolete_combination
        end

        def obsolete_combination_name
          genus_name_part = obsolete_genus.name.name
          species_name_part = current_taxon.name.epithet
          new_name_string = "#{genus_name_part} #{species_name_part}"

          SpeciesName.new(name: new_name_string)
        end
    end
  end
end
