# frozen_string_literal: true

module Taxa
  class BuildTaxon
    include Service

    def initialize rank_to_create, parent, taxon_params: {}, authorship_params: {}
      @rank_to_create = rank_to_create
      @parent = parent
      @taxon_params = taxon_params
      @authorship_params = authorship_params
    end

    def call
      taxon = build_taxon
      taxon.parent = parent
      taxon
    end

    private

      attr_reader :rank_to_create, :parent, :taxon_params, :authorship_params

      def build_taxon
        taxon = taxon_class.new
        taxon.name = taxon.name_class.new
        taxon.build_protonym
        taxon.protonym.build_name
        taxon.protonym.build_authorship
        taxon.protonym.authorship.attributes = authorship_params if authorship_params.present?
        taxon.attributes = taxon_params if taxon_params.present?
        taxon
      end

      def taxon_class
        rank_to_create.to_s.constantize
      end
  end
end
