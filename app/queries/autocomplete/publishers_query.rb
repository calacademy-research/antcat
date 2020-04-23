# frozen_string_literal: true

module Autocomplete
  class PublishersQuery
    include Service

    attr_private_initialize :search_query

    def call
      search_results
    end

    private

      def search_results
        Publisher.
          where("CONCAT(COALESCE(publishers.place, ''), ':', publishers.name) LIKE ?", search_expression)
      end

      def search_expression
        '%' + search_query.split('').join('%') + '%'
      end
  end
end
