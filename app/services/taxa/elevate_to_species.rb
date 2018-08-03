module Taxa
  class ElevateToSpecies
    include Service
    include Formatters::ItalicsHelper

    def initialize taxon
      @taxon = taxon
    end

    def call
      elevate_to_species
    end

    private

      attr_reader :taxon

      delegate :name, :species, :create_activity, :name_html_cache, to: :taxon

      def elevate_to_species
        raise NoSpeciesForSubspeciesError unless species
        # Removed commented out code + comments that looked very WIP.
        # See 37064da56f47a530a388b268289a73cb24b93d75.

        new_name_string = "#{species.genus.name.name} #{name.epithet}"
        new_name = SpeciesName.find_by_name new_name_string
        unless new_name
          new_name = SpeciesName.new
          new_name.update name: new_name_string,
                          name_html: italicize(new_name_string),
                          epithet: name.epithet,
                          epithet_html: name.epithet_html,
                          epithets: nil
          new_name.save
        end

        create_elevate_to_species_activity new_name

        # TODO no not use `#update_columns`.
        taxon.update_columns name_id: new_name.id,
                             species_id: nil,
                             name_cache: new_name.name,
                             name_html_cache: new_name.name_html,
                             type: 'Species'
      end

      def create_elevate_to_species_activity new_name
        create_activity :elevate_subspecies_to_species,
          parameters: { name_was: name_html_cache, name: new_name.name_html }
      end
  end
end
