module Autocomplete
  class AuthorNames
    include Service

    def initialize search_query = ''
      @search_query = search_query
    end

    def call
      AuthorName.where('name LIKE ?', "%#{search_query}%")
        .includes(:reference_author_names)
        .order('reference_author_names.created_at DESC', 'name')
        .map(&:name)
    end

    private
      attr_reader :search_query
  end
end
