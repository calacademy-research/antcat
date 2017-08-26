module Autocomplete
  class LinkableJournals
    def initialize search_query
      @search_query = search_query
    end

    def call
      # See if we have an exact ID match.
      search_results = if search_query =~ /^\d+ ?$/
                         id_matches_q = Journal.find_by id: search_query
                         [id_matches_q] if id_matches_q
                       end

      search_results ||= Journal.where("name LIKE ?", "%#{search_query}%")

      search_results.map do |journal|
        { id: journal.id, name: journal.name }
      end
    end

    private
      attr_reader :search_query
  end
end
