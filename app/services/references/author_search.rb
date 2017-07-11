module References
  class AuthorSearch
    def initialize author_names_query, page = nil
      @author_names_query = author_names_query
      @page = page
    end

    def call
      author_names = Parsers::AuthorParser.parse(author_names_query)[:names]
      authors = Author.find_by_names author_names

      query = Reference.select('`references`.*')
        .joins(:author_names)
        .joins('JOIN authors ON authors.id = author_names.author_id')
        .where('authors.id IN (?)', authors)
        .group('references.id')
        .having("COUNT(`references`.id) = #{authors.size}")
        .order(:author_names_string_cache, :citation_year)
      query.paginate page: (page || 1)
    end

    private
      attr_reader :author_names_query, :page
  end
end
