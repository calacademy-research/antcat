# frozen_string_literal: true

module DatabaseScripts
  class CitationsWithPagesBeforeReferencesPagination < DatabaseScript
    LIMIT = 100

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      Protonym.limit(10).joins(authorship: :reference).
        where(references: { type: 'ArticleReference' }).
        where("CAST(pages AS UNSIGNED) < CAST(pagination AS UNSIGNED)").
        includes(:name, authorship: [reference: :document]).
        limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Authorship pages', 'Reference', 'Reference pagination', 'PDF'
        t.rows do |protonym|
          reference = protonym.authorship_reference
          citation = protonym.authorship

          [
            protonym.decorate.link_to_protonym,
            protonym.author_citation,
            citation.pages,
            link_to(reference.key_with_citation_year, reference_path(reference)),
            reference.pagination,
            reference.decorate.pdf_link
          ]
        end
      end
    end
  end
end

__END__

section: main
category: References
tags: [slow-render]

description: >
  First batch of citations with mismatching pages.


  "Citations" as in `Citation` records, (which are currently only used by `Protonym`s).


  Only article references are checked.


  Complicated pages/paginations will not show up, or show up as false positives, for example references with pagination like `123 pp.`.

related_scripts:
  - CitationsWithPagesBeforeReferencesPagination
