# TODO: See if we want to use this instead of `AutocompleteJournals`, or remove this.

module Autocomplete
  class AutocompleteLinkableJournals
    include Service

    def initialize search_query
      @search_query = search_query
    end

    def call
      search_results.map do |journal|
        {
          id: journal.id,
          name: journal.name
        }
      end
    end

    private

      attr_reader :search_query

      def search_results
        exact_id_match || Journal.where("name LIKE ?", "%#{search_query}%")
      end

      def exact_id_match
        return unless search_query =~ /^\d+ ?$/

        match = Journal.find_by id: search_query
        [match] if match
      end
  end
end
