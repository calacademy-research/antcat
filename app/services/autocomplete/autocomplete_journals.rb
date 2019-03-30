module Autocomplete
  class AutocompleteJournals
    include Service

    def initialize search_query
      @search_query = search_query
    end

    def call
      Journal.select('journals.name, COUNT(*)').
        left_outer_joins(:references).
        where('journals.name LIKE ?', search_expression).
        group('journals.id').
        order(Arel.sql('COUNT(*) DESC')).
        pluck(:name)
    end

    private

      attr_reader :search_query

      def search_expression
        search_query.split('').join('%') + '%'
      end
  end
end
