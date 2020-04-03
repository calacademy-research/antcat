# frozen_string_literal: true

module Autocomplete
  class AutocompleteProtonyms
    include Service

    attr_private_initialize :search_query

    def call
      (exact_id_match || search_results).map do |protonym|
        {
          id: protonym.id,
          name_with_fossil: protonym.decorate.name_with_fossil,
          author_citation: protonym.authorship.reference.keey_without_letters_in_year
        }
      end
    end

    private

      def search_results
        Protonym.
          joins(:name).
          where("names.name LIKE ? OR names.name LIKE ?", crazy_search_query, not_as_crazy_search_query).
          take(10)
      end

      def crazy_search_query
        search_query.split('').join('%') + '%'
      end

      def not_as_crazy_search_query
        "%#{search_query}%"
      end

      def exact_id_match
        return unless /^\d+ ?$/.match?(search_query)

        match = Protonym.find_by(id: search_query)
        [match] if match
      end
  end
end
