# frozen_string_literal: true

module Taxa
  class CopyAttributes
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      taxon.slice(attributes_to_copy)
    end

    private

      attr_reader :taxon

      # Not copied:
      #  :name (and cached :name_cache, :name_html_cache)
      #  :hol_id
      #  :origin
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
          :type_taxt,
          :headline_notes_taxt,
          :hong,
          :unresolved_homonym,
          :current_valid_taxon_id,
          :ichnotaxon,
          :nomen_nudum,
          :type_taxon_id
        ]
      end
  end
end
