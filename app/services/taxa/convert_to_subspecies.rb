module Taxa
  class ConvertToSubspecies
    include Service
    include Formatters::ItalicsHelper

    def initialize original_species, new_species_parent
      @original_species = original_species
      @new_species_parent = new_species_parent
    end

    def call
      return false if original_species.subspecies.exists?

      new_subspecies = build_new_subspecies

      if Taxon.find_by_name(new_subspecies.name.name)
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
        taxon.save_initiator = true
        taxon.attributes = Taxa::CopyAttributes[original_species]
        taxon.species = new_species_parent
        taxon.name = subspecies_name
        taxon
      end

      def subspecies_name
        new_name_string = "#{new_species_parent.genus.name.name} #{new_species_parent.name.epithet} #{original_species.name.epithet}"

        new_name = SubspeciesName.find_by_name new_name_string

        return new_name if new_name

        # TODO make the `Name` classes set epithets and HTML names.
        SubspeciesName.new name: new_name_string,
          name_html: italicize(new_name_string),
          epithet: original_species.name.epithet,
          epithet_html: original_species.name.epithet_html,
          epithets: "#{new_species_parent.name.epithet} #{original_species.name.epithet}"
      end

      def move_history_items! new_subspecies
        Taxa::MoveItems[new_subspecies, original_species.history_items]
      end
  end
end
