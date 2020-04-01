# frozen_string_literal: true

module Autocomplete
  class AutocompleteAuthorNames
    include Service

    attr_private_initialize :search_query

    def call
      AuthorName.where('name LIKE ?', "%#{search_query}%").
        includes(:reference_author_names).
        distinct.
        order('reference_author_names.created_at DESC', 'name')
    end
  end
end
