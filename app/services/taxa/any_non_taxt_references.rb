module Taxa
  class AnyNonTaxtReferences
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      any_references_in_taxa?
    end

    private

      attr_reader :taxon

      delegate :id, to: :taxon

      def any_references_in_taxa?
        Taxon::TAXA_FIELDS_REFERENCING_TAXA.each do |field|
          return true if Taxon.where(field => id).exists?
        end
        false
      end
  end
end
