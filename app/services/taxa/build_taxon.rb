# frozen_string_literal: true

module Taxa
  class BuildTaxon
    include Service

    attr_private_initialize :rank_to_create, :parent

    def call
      taxon = build_taxon
      taxon.parent = parent
      taxon
    end

    private

      def build_taxon
        taxon = taxon_class.new
        taxon.name = taxon.name_class.new
        taxon.build_protonym
        taxon.protonym.build_name
        taxon.protonym.build_authorship
        taxon
      end

      def taxon_class
        rank_to_create.to_s.constantize
      end
  end
end
