# frozen_string_literal: true

module DatabaseScripts
  class NestedReferencesWithLessParsablePagination < DatabaseScript
    LIMIT = 300

    def results
      NestedReference.where.not('pagination REGEXP ?', "^Pp?\. [0-9]+(-[0-9]+)? in:$").limit(LIMIT)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})
      STR
    end

    def render
      as_table do |t|
        t.header 'Reference', 'Pagination'
        t.rows do |reference|
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
  - ArticleReferencesWithLessParsablePagination
  - BookReferencesWithLessParsablePagination
  - NestedReferencesWithLessParsablePagination
