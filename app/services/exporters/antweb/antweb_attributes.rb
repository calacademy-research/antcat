# frozen_string_literal: false

# TODO: Strings are not frozen due to `col.delete!("\n")` in `Exporters::Antweb::Exporter`.

module Exporters
  module Antweb
    class AntwebAttributes
      include Service

      attr_private_initialize :taxon

      def call
        case taxon
        when Family     then family_attributes
        when Subfamily  then subfamily_attributes
        when Tribe      then tribe_attributes
        when Genus      then genus_attributes
        when Subgenus   then subgenus_attributes
        when Species    then species_attributes
        when Subspecies then subspecies_attributes
        else                 {}
        end
      end

      private

        delegate :name, :subfamily, :tribe, :genus, :subgenus, :species, to: :taxon

        def family_attributes
          {
            subfamily: 'Formicidae'
          }
        end

        def subfamily_attributes
          {
            subfamily: name.name
          }
        end

        def tribe_attributes
          {
            subfamily: subfamily.name.name,
            tribe: name.name
          }
        end

        def genus_attributes
          {
            subfamily: subfamily&.name&.name || 'incertae_sedis',
            tribe: tribe&.name&.name,
            genus: name.name
          }
        end

        def subgenus_attributes
          {
            subfamily: subfamily&.name&.name || 'incertae_sedis',
            genus: genus.name.name,
            subgenus: name.epithet
          }
        end

        def species_attributes
          {
            subfamily: genus.subfamily&.name&.name || 'incertae_sedis',
            tribe: genus.tribe&.name&.name,
            genus: genus.name.name,
            subgenus: subgenus&.name&.epithet,
            species: name.epithet
          }
        end

        def subspecies_attributes
          {
            subfamily: genus.subfamily&.name&.name || 'incertae_sedis',
            tribe: genus.tribe&.name&.name,
            genus: genus.name.name,
            subgenus: species.subgenus&.name&.epithet,
            species: name.species_epithet,
            subspecies: name.epithet
          }
        end
    end
  end
end
