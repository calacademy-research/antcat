# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithLessParsablePagination < DatabaseScript
    LIMIT = 100

    def article_results
      ArticleReference.where.not('pagination REGEXP ?', "^[0-9]+(-[0-9]+)?$").limit(LIMIT)
    end

    def book_results
      BookReference.where.not('pagination REGEXP ?', "^[0-9]+ pp\.$").limit(LIMIT)
    end

    def nested_results
      NestedReference.where.not('pagination REGEXP ?', "^Pp?\. [0-9]+(-[0-9]+)? in:$").limit(LIMIT)
    end

    def statistics
      <<~STR.html_safe
        Article results: #{article_results.limit(nil).count} (showing first #{LIMIT})<br><br>
        Book results: #{book_results.limit(nil).count} (showing first #{LIMIT})<br><br>
        Nested results: #{nested_results.limit(nil).count} (showing first #{LIMIT})<br><br>
      STR
    end

    def render
      render_table(article_results) +
        render_table(book_results) +
        render_table(nested_results)
    end

    def render_table table_results
      as_table do |t|
        t.caption "Results: #{table_results.limit(nil).count} (showing first #{LIMIT})"
        t.header 'Reference', 'Pagination'
        t.rows(table_results) do |reference|
          [
            link_to(reference.key_with_citation_year, reference_path(reference)),
            reference.pagination
          ]
        end
      end
    end
  end
end

__END__

section: research
category: References
tags: [new!]

issue_description:

description: >
  This is not incorrect, and we have to handle Roman numerals before this becomes useful.

related_scripts:
  - ReferencesWithLessParsablePagination
