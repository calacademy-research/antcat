module Autocomplete
  class AutocompletePublishers
    include Service

    def initialize search_query
      @search_query = search_query
    end

    def call
      Publisher.joins('LEFT OUTER JOIN places ON place_id = places.id').
        where("CONCAT(COALESCE(places.name, ''), ':', publishers.name) LIKE ?", search_expression).
        map(&:display_name)
    end

    private

      attr_reader :search_query

      def search_expression
        '%' + search_query.split('').join('%') + '%'
      end
  end
end
