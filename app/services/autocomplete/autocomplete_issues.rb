module Autocomplete
  class AutocompleteIssues
    include Service

    def initialize search_query
      @search_query = search_query
    end

    def call
      search_results.map do |issue|
        {
          id: issue.id,
          title: issue.title,
          status: issue.decorate.format_status
        }
      end
    end

    private

      attr_reader :search_query

      def search_results
        exact_id_match || Issue.where("title LIKE ?", "%#{search_query}%")
      end

      def exact_id_match
        return unless search_query =~ /^\d+ ?$/

        match = Issue.find_by id: search_query
        [match] if match
      end
  end
end
