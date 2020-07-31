# frozen_string_literal: true

module Api
  module V1
    class TaxonSerializer
      ATTRIBUTES = [
        :id,
        :auto_generated,
        :collective_group_name,
        :current_taxon_id,
        :family_id,
        :fossil,
        :genus_id,
        :hol_id,
        :homonym_replaced_by_id,
        :hong,
        :ichnotaxon,
        :incertae_sedis_in,
        :name_cache,
        :name_html_cache,
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
        taxon.as_json(only: ATTRIBUTES, methods: :author_citation, root: true)
      end
    end
  end
end
