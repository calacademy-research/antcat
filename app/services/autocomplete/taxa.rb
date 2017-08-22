module Autocomplete
  class Taxa
    def initialize search_query
      @search_query = search_query
    end

    def call
      # See if we have an exact ID match.
      search_results = if search_query =~ /^\d{6} ?$/
                         id_matches_q = Taxon.find_by id: search_query
                         [id_matches_q] if id_matches_q
                       end

      search_results ||= Taxon.where("name_cache LIKE ?", "%#{search_query}%")
        .includes(:name, protonym: { authorship: :reference }).take(10)

      search_results.map do |taxon|
        { id: taxon.id,
          name: taxon.name_cache,
          name_html: taxon.name_html_cache,
          authorship_string: taxon.authorship_string
        }
      end
    end

    private
      attr_reader :search_query
  end
end
