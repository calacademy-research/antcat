module Taxa
  class AnyNonTaxtReferences
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      any_references_in_taxa? || any_references_in_synonyms?
    end

    private
      attr_reader :taxon

      delegate :id, :synonyms_as_senior, :synonyms_as_junior, to: :taxon

      def any_references_in_taxa?
        Taxon::TAXA_FIELDS_REFERENCING_TAXA.each do |field|
          return true if Taxon.where(field => id).exists?
        end
        false
      end

      def any_references_in_synonyms?
        synonyms_as_senior.exists? || synonyms_as_junior.exists?
      end
    end
end
