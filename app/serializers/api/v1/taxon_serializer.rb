# frozen_string_literal: true

module Api
  module V1
    class TaxonSerializer
      ATTRIBUTES = [
        :id,
        :collective_group_name,
        :current_taxon_id,
        :family_id,
        :fossil,
        :genus_id,
        :hol_id,
        :homonym_replaced_by_id,
        :incertae_sedis_in,
        :name_cache,
        :name_id,
        :original_combination,
        :protonym_id,
        :species_id,
        :status,
        :subfamily_id,
        :subgenus_id,
        :subspecies_id,
        :tribe_id,
        :unresolved_homonym,

        :created_at,
        :updated_at
      ]

      attr_private_initialize :taxon

      def as_json _options = {}
        {
          taxon.model_name.element => taxon_attributes.merge(name_html_cache: taxon.name.name_html).as_json
        }
      end

      private

        def taxon_attributes
          taxon.serializable_hash(only: ATTRIBUTES, methods: :author_citation)
        end
    end
  end
end
