# frozen_string_literal: true

module Autocomplete
  class JournalsQuery
    include Service

    attr_private_initialize :search_query

    def call
      search_results
    end

    private

      def search_results
        Journal.
          left_outer_joins(:references).
          where('journals.name LIKE ?', search_expression).
          group('journals.id').
          order(Arel.sql('COUNT(*) DESC'))
      end

      def search_expression
        search_query.split('').join('%') + '%'
      end
  end
end
