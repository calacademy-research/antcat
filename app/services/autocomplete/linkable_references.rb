module Autocomplete
  class LinkableReferences
    def initialize search_query
      @search_query = search_query
    end

    def call
      # TODO create concern? There's similar logic in other controllers.
      # See if we have an exact ID match.
      search_results =  if search_query =~ /^\d{6} ?$/
                          id_matches_q = Reference.find_by id: search_query
                          [id_matches_q] if id_matches_q
                        end
      search_results ||= Reference.fulltext_search_light search_query

      search_results.map do |reference|
        { id: reference.id,
          author: reference.author_names_string,
          year: reference.citation_year,
          title: reference.decorate.format_title
        }
      end
    end

    private
      attr_reader :search_query
  end
end
