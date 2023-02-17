# frozen_string_literal: true

module Exporters
  module Antweb
    class TaxonomicAttributes
      include Service

      INCERTAE_SEDIS = 'incertae_sedis'
      FORMICIDAE = 'Formicidae'

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
        else            raise "rank '#{taxon.type}' not supported"
        end
      end

      private

        delegate :name, :subfamily, :tribe, :genus, :subgenus, :species, to: :taxon, private: true

        def family_attributes
          {
            subfamily: FORMICIDAE
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
            subfamily: subfamily&.name&.name || INCERTAE_SEDIS,
            tribe: tribe&.name&.name,
            genus: name.name
          }
        end

        def subgenus_attributes
          {
            subfamily: subfamily&.name&.name || INCERTAE_SEDIS,
            genus: genus.name.name,
            subgenus: name.epithet
          }
        end

        def species_attributes
          {
            subfamily: genus.subfamily&.name&.name || INCERTAE_SEDIS,
            tribe: genus.tribe&.name&.name,
            genus: genus.name.name,
            subgenus: subgenus&.name&.epithet,
            species: name.epithet
          }
        end

        def subspecies_attributes
          {
            subfamily: genus.subfamily&.name&.name || INCERTAE_SEDIS,
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
