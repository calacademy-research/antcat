module Autocomplete
  class Taxa
    include Service

    def initialize search_query
      @search_query = search_query
    end

    def call
      search_results.map do |taxon|
        {
          id: taxon.id,
          name: taxon.name_cache,
          name_html: taxon.name_html_cache,
          authorship_string: taxon.authorship_string
        }
      end
    end

    private
      attr_reader :search_query


      def search_results
        exact_id_match || Taxon.where("name_cache LIKE ?", "%#{search_query}%")
          .includes(:name, protonym: { authorship: :reference }).take(10)
      end

      def exact_id_match
        return unless search_query =~ /^\d{6} ?$/

        match = Taxon.find_by id: search_query
        [match] if match
      end
  end
end
