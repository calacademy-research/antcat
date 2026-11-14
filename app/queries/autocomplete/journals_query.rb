# frozen_string_literal: true

# Autocomplete: journal names containing the typed text, most used first (reference form).
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
          left_joins(:references).
          where('journals.name LIKE ?', search_expression).
          group('journals.id').
          # Number of references, so a journal without references counts 0 (`COUNT(*)` gave 1). Arel quotes the
          # table name: `references` is a reserved word in MySQL.
          order(Reference.arel_table[:id].count.desc)
      end

      def search_expression
        search_query.chars.join('%') + '%'
      end
  end
end
