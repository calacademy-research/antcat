module Taxa
  class ConvertToSubspeciesOf
    include Service
    include Formatters::ItalicsHelper

    def initialize taxon, species
      @taxon = taxon
      @species = species
    end

    def call
      become_subspecies_of_species
    end

    private

      attr_reader :taxon, :species

      delegate :name, :create_activity, :name_html_cache, to: :taxon

      def become_subspecies_of_species
        new_name_string = "#{species.genus.name.name} #{species.name.epithet} #{name.epithet}"
        if Subspecies.find_by_name new_name_string
          raise Taxon::TaxonExists, "The subspecies '#{new_name_string}' already exists."
        end

        new_name = SubspeciesName.find_by_name new_name_string
        unless new_name
          new_name = SubspeciesName.new
          new_name.update name: new_name_string,
                          name_html: italicize(new_name_string),
                          epithet: name.epithet,
                          epithet_html: name.epithet_html,
                          epithets: "#{species.name.epithet} #{name.epithet}"
          new_name.save
        end

        create_convert_species_to_subspecies_activity new_name

        # TODO no not use `#update_columns`.
        taxon.update_columns name_id: new_name.id,
                             species_id: species.id,
                             name_cache: new_name.name,
                             name_html_cache: new_name.name_html,
                             type: 'Subspecies'
      end

      def create_convert_species_to_subspecies_activity new_name
        create_activity :convert_species_to_subspecies,
          parameters: { name_was: name_html_cache, name: new_name.name_html }
      end
  end
end
