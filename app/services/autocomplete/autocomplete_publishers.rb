module Autocomplete
  class AutocompletePublishers
    include Service

    def initialize search_query
      @search_query = search_query
    end

    def call
      Publisher.
        where("CONCAT(COALESCE(publishers.place_name, ''), ':', publishers.name) LIKE ?", search_expression)
    end

    private

      attr_reader :search_query

      def search_expression
        '%' + search_query.split('').join('%') + '%'
      end
  end
end
