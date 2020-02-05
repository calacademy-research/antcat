module Taxa
  class BuildTaxon
    include Service

    def initialize rank_to_create, parent
      @rank_to_create = rank_to_create
      @parent = parent
    end

    def call
      taxon = build_taxon
      taxon.parent = parent
      taxon
    end

    private

      attr_reader :rank_to_create, :parent

      def build_taxon
        taxon = taxon_class.new
        taxon.build_name
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
