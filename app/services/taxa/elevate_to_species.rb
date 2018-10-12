module Taxa
  class ElevateToSpecies
    include Service
    include Formatters::ItalicsHelper

    def initialize subspecies
      @subspecies = subspecies
    end

    def call
      new_species = build_new_species

      if Taxon.find_by_name(new_species.name.name)
        new_species.errors.add :base, "This name is in use by another taxon"
        return new_species
      end

      if new_species.save
        move_history_items! new_species
      end

      new_species
    end

    private

      attr_reader :subspecies

      def build_new_species
        taxon = Species.new
        taxon.save_initiator = true
        taxon.attributes = Taxa::CopyAttributes[subspecies]
        taxon.genus = subspecies.genus
        taxon.name = species_name
        taxon
      end

      def species_name
        species = subspecies.species
        new_name_string = "#{species.genus.name.name} #{subspecies.name.epithet}"

        new_name = SpeciesName.find_by_name new_name_string

        return new_name if new_name

        # TODO the `Name` classes set the epithets and HTML names.
        SpeciesName.new name: new_name_string,
          name_html: italicize(new_name_string),
          epithet: subspecies.name.epithet,
          epithet_html: subspecies.name.epithet_html,
          epithets: nil
      end

      def move_history_items! new_species
        Taxa::MoveItems[new_species, subspecies.history_items]
      end
  end
end
