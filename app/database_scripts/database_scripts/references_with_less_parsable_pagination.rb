# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithLessParsablePagination < DatabaseScript
    LIMIT = 150
    ROMAN_NUMERALS = 'ivxlcdm'

    def empty_status
      DatabaseScripts::EmptyStatus::FALSE_POSITIVES
    end

    def article_results
      ArticleReference.
        where.not('pagination REGEXP ?', "^[0-9]+(-[0-9]+)?$").
        where.not('pagination REGEXP ?', "^[#{ROMAN_NUMERALS}]+(-[#{ROMAN_NUMERALS}]+)?$").
        where.not('pagination REGEXP ?', "^e[0-9]+$").
        where.not('pagination REGEXP ?', "^[0-9]+ pp. e[0-9]+$").
        limit(LIMIT)
    end

    def book_results
      BookReference.
        where.not('pagination REGEXP ?', "^[0-9]+ pp\.$").
        where.not('pagination REGEXP ?', "^[#{ROMAN_NUMERALS}]+ \\+ [0-9]+ pp\.$").
        limit(LIMIT)
    end

    def nested_results
      NestedReference.
        where.not('pagination REGEXP ?', "^Pp?\. [0-9]+(-[0-9]+)? in:$").
        where.not('pagination REGEXP ?', "^Pp?\. [0-9]+(-[0-9]+)?, [0-9]+(-[0-9]+)? in:$").
        where.not('pagination REGEXP ?', "^Pp?\. [#{ROMAN_NUMERALS}]+(-[#{ROMAN_NUMERALS}]+)? in:$").
        limit(LIMIT)
    end

    def statistics
      <<~STR.html_safe
        Article results: #{article_results.limit(nil).count}<br><br>
        Book results: #{book_results.limit(nil).count}<br><br>
        Nested results: #{nested_results.limit(nil).count}<br><br>
      STR
    end

    def render
      render_table(article_results, 'Article') +
        render_table(book_results, 'Book') +
        render_table(nested_results, 'Nested')
    end

    def render_table table_results, reference_type
      as_table do |t|
        t.caption "#{reference_type} references results: #{table_results.limit(nil).count} (showing first #{LIMIT})"
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
tags: []

issue_description:

description: >
  This is not incorrect, and we have to handle more formats before this becomes useful.

related_scripts:
  - ReferencesWithLessParsablePagination
