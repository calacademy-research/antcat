module Autocomplete
  class Issues
    def initialize search_query
      @search_query = search_query
    end

    def call
      # See if we have an exact ID match.
      search_results = if search_query =~ /^\d+ ?$/
                         id_matches_q = Issue.find_by id: search_query
                         [id_matches_q] if id_matches_q
                       end

      search_results ||= Issue.where("title LIKE ?", "%#{search_query}%")

      search_results.map do |issue|
        { id: issue.id, title: issue.title, status: issue.decorate.format_status }
      end
    end

    private
      attr_reader :search_query
  end
end
