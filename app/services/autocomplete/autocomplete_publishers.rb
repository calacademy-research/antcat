# frozen_string_literal: true

module Autocomplete
  class AutocompletePublishers
    include Service

    attr_private_initialize :search_query

    def call
      Publisher.
        where("CONCAT(COALESCE(publishers.place, ''), ':', publishers.name) LIKE ?", search_expression)
    end

    private

      def search_expression
        '%' + search_query.split('').join('%') + '%'
      end
  end
end
