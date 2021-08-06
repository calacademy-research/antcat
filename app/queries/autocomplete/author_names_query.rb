# frozen_string_literal: true

module Autocomplete
  class AuthorNamesQuery
    include Service

    attr_private_initialize :search_query

    def call
      search_results
    end

    private

      def search_results
        AuthorName.where('name LIKE ?', "%#{search_query}%")
      end
  end
end
