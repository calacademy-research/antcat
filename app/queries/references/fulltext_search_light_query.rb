# frozen_string_literal: true

# Fulltext search, but not all fields. Used by at.js.
# TODO: This class is building up more and more duplication w.r.t `References::FulltextSearchQuery`.
# TODO: We may want to use the same order/boost for `References::FulltextSearchQuery`.

module References
  class FulltextSearchLightQuery
    include Service

    attr_private_initialize :search_query

    def call
      search_results
    end

    private

      def search_results
        Reference.search do
          keywords normalized_search_query do
            fields :title, :author_names_string, :citation_year, :stated_year, :bolton_key, :authors_for_keey
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
      # TODO: This is partially duplicated in `References::FulltextSearchQuery`.
      def normalized_search_query
        search_query.gsub(/-|:/, ' ')
      end
  end
end
