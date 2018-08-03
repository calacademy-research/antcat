module Taxa
  class CurrentValidTaxonIncludingSynonyms
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      current_valid_taxon_including_synonyms
    end

    private

      attr_reader :taxon

      delegate :synonym?, :current_valid_taxon, to: :taxon

      def current_valid_taxon_including_synonyms
        if synonym?
          senior = find_most_recent_valid_senior_synonym taxon
          return senior if senior
        end
        current_valid_taxon
      end

      # Spec randomly fails, see notes in spec file.
      # TODO change to `order(created_at: :id)`.
      def find_most_recent_valid_senior_synonym taxon
        return unless taxon.senior_synonyms
        taxon.senior_synonyms.order(created_at: :desc).each do |senior_synonym|
          return senior_synonym unless senior_synonym.invalid?
          return nil unless senior_synonym.synonym?
          return find_most_recent_valid_senior_synonym senior_synonym
        end
        nil
      end
  end
end
