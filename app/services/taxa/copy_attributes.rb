# frozen_string_literal: true

# The attributes of a taxon that are copied to a taxon made from it (a new combination, a converted rank).
module Taxa
  class CopyAttributes
    include Service

    attr_private_initialize :taxon

    def call
      taxon.slice(attributes_to_copy)
    end

    private

      # Not copied:
      #  :name
      #  :name_cache
      #  :hol_id
      #  ... and more
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
          :status,
          :homonym_replaced_by_id,
          :incertae_sedis_in,
          :protonym_id,
          :unresolved_homonym,
          :current_taxon_id
        ]
      end
  end
end
