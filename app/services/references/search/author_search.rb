module References
  module Search
    class AuthorSearch
      include Service

      def initialize search_query, page = nil
        @search_query = search_query
        @page = page
      end

      def call
        Reference.select('`references`.*')
          .joins(:author_names)
          .joins('JOIN authors ON authors.id = author_names.author_id')
          .where('authors.id IN (?)', authors)
          .group('references.id')
          .having("COUNT(`references`.id) = #{authors.size}")
          .order(:author_names_string_cache, :citation_year)
          .paginate page: (page || 1)
      end

      private

        attr_reader :search_query, :page

        def authors
          Author.find_by_names author_names
        end

        def author_names
          Parsers::AuthorParser.parse(search_query)[:names]
        end
    end
  end
end
