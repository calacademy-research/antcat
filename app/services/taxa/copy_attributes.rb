# frozen_string_literal: true

module Taxa
  class CopyAttributes
    include Service

    attr_private_initialize :taxon

    def call
      taxon.slice(attributes_to_copy)
    end

    private

      # Not copied:
      #  :name (and cached :name_cache, :name_html_cache)
      #  :hol_id
      #
      #  Taxonomic relationships:
      #    :subfamily,
      #    :tribe,
      #    :genus,
      #    :species,
      #    :subgenus,
      #    :name,
      #    :family
      #
      # In the order the appear in `schema.rb`.
      def attributes_to_copy
        [
          :fossil,
          :status,
          :homonym_replaced_by_id,
          :incertae_sedis_in,
          :protonym_id,
          :hong,
          :unresolved_homonym,
          :current_taxon_id,
          :ichnotaxon
        ]
      end
  end
end
