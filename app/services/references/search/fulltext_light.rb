# Fulltext search, but not all fields. Used by at.js.
# TODO this class is building up more and more duplication w.r.t `References::Search::Fulltext`.
# TODO we may want to use the same order/boost for `References::Search::Fulltext`.

module References
  module Search
    class FulltextLight
      include Service

      def initialize search_query
        @search_query = search_query
      end

      def call
        fulltext_search_light
      end

      private

        attr_reader :search_query

        def fulltext_search_light
          Reference.search do
            keywords normalized_search_query do
              fields :title, :author_names_string, :citation_year, :bolton_key, :authors_for_keey
              boost_fields author_names_string: 5.0
              boost_fields citation_year: 2.0
            end

            order_by :score, :desc
            order_by :author_names_string, :desc
            order_by :citation_year, :asc
            paginate page: 1, per_page: 15
          end.results
        end

        # Hyphens, asterixes and colons makes Solr go bananas.
        # TODO: This is partially duplicated in `References::Search::Fulltext`.
        def normalized_search_query
          search_query.gsub(/-|:/, ' ')
        end
    end
  end
end
